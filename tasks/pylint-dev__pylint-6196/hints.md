Let me give an example on this point, as I think it is the most problematic:

> Applying the decorator to a callback that not only emits messages but also does other things can have nasty side effects (false positives, false negatives, crashes)

The checker I wanted to prepare has a good example for that. The relevant parts can be stripped down to this:

```python
class MessagesChecker(BaseChecker):
    """Checks if messages are handled correctly in checker classes."""

    __implements__ = (IAstroidChecker,)
    name = "messages_checker"

    def __init__(self, linter: PyLinter) -> None:
        super().__init__(linter)
        # List of all messages defined in the checker's msgs attribute
        self._defined_messages = None

    def visit_classdef(self, node: nodes.ClassDef) -> None:
        if not _is_checker_class(node):
            return
        self._defined_messages = _get_defined_messages(node)

    @check_messages("undefined-message")
    def visit_call(self, node: nodes.Call) -> None:
        ... # omitted: check if this is a ``self.add_message`` call and extract the msgid
        if msgid not in self._defined_messages:
            self.add_message("undefined-message", node=node, args=(msgid,))
```
``visit_classdef`` does not emit messages itself, so it is not decorated with ``@check_messages``. But it sets the ``self._defined_messages`` attribute, which is needed by ``visit_call``.

Now imagine a new message is added, for example "inconsistent-message-ids", which is checked from the ``visit_classdef`` method. One could be very tempted to now apply the ``@check_messages`` decorator to ``visit_classdef``:

```python
    """Checks if messages are handled correctly in checker classes."""

    __implements__ = (IAstroidChecker,)
    name = "messages_checker"

    def __init__(self, linter: PyLinter) -> None:
        super().__init__(linter)
        # List of all messages defined in the checker's msgs attribute
        self._defined_messages: Dict[Str, nodes.Dict] = {}

    @check_messages("inconsistent-message-ids")  # <-- ADDED
    def visit_classdef(self, node: nodes.ClassDef) -> None:
        if not _is_checker_class(node):
            return
        self._defined_messages = _get_defined_messages(node)
        self._check_inconsistent_message_ids()  # <-- ADDED

    @check_messages("undefined-message")
    def visit_call(self, node: nodes.Call) -> None:
        ... # omitted: check if this is a ``self.add_message`` call and extract the msgid
        if msgid not in self._defined_messages:
            self.add_message("undefined-message", node=node, args=(msgid,))
```
Looks good, doesn't it? 
But if you decide you don't want to be bothered by the new message and run with ``--disable=inconsistent-message-ids``, you will be greeted with:
```shell
TypeError: argument of type 'NoneType' is not iterable
```

So, what happened? By adding the ``@check_messages`` decorator to ``visit_classdef``, we told ``ASTWalker`` that he can safely skip this callback if none of the messages passed into it is enabled, leaving ``self._defined_messages`` on its default ``None`` value. 


**My proposal:**
It would be best to rename ``check_messages`` to something like ``only_required_for``.
It very clearly conveys *where this decorator can be placed*, and maybe even gives a small hint *what the effect of this decorator may be*.
Every developer would be a lot more hesitant to just add ``@only_required_for("inconsistent-message-ids")`` to any existing code as in the example above, while ``@check_messages("inconsistent-message-ids")`` seemed the reasonable thing to do.

We could do this in steps:
1. Rename ``check_messages`` to ``only_required_for`` with a meaningful docstring, but keep ``check_messages`` as alias. This way we do not have to fix all occurrences in the code base in a single PR and also remain compatible with custom checkers users may have wrote that still use ``check_messages``.
2. Add clear documentation what ``only_required_for`` does in [How to write a Checker](https://pylint.pycqa.org/en/latest/how_tos/custom_checkers.html#how-to-write-a-checker)
3. Replace and clean up the ``@check_messages`` decorators on existing checkers - we could do one checker per PR to ease reviews.
4. Issue a ``DeprecationWarning`` if ``check_messages`` is used instead of ``only_required_for``

What do you think?


@DudeNr33 Thanks for this extensive write-up. I agree with most points here and I think this can/is indeed problematic.

I had one question though: have you checked how much of a performance benefit this actually gives? Even if we rename to `only_required_for` it is easy to miss it in `visit_` methods of 100+ lines (which there are). I think knowing the actual performance benefit would be important to know if we should even keep supporting this functionality or just deprecate it altogether.
> @DudeNr33 Thanks for this extensive write-up.

Yeah that's very useful I was using it without understanding it properly personally. It probably contributed to hard to debug issues along the way.

I like the proposed steps. 

If the performance improvment is worth it, we could also create our own internal checker to verify that it's on a function when there is no side effectand conversely  that there is no side effects if it's on a function.
> I had one question though: have you checked how much of a performance benefit this actually gives

No, I haven't. The question is what we should measure here. 
Measuring the impact of disabling just a single message could be done with a script. But I already saw that a lot of times many messages are not properly included in existing ``@check_messages`` decorators, so the results would not really mean that much.
Probably more interesting would be the performance gains for users who run ``pylint`` with just specific categories, for example just "-E", or who disable specific message categories. 
I wrote a small script to get a first estimate (it only runs ``pylint`` once, so no real statistics...):

**With check_messages active:**
Disabled category: E - Elapsed time: 19.727s (28 callbacks ignored)
Disabled category: F - Elapsed time: 15.952s (4 callbacks ignored)
Disabled category: R - Elapsed time: 6.632s  (10 callbacks ignored)
Disabled category: C - Elapsed time: 15.851s (15 callbacks ignored)
Disabled category: W - Elapsed time: 14.878s (38 callbacks ignored)
Disabled category: I - Elapsed time: 15.685s (4 callbacks ignored)

**With check_messages replaced with a dummy:**
Disabled category: E - Elapsed time: 20.557s
Disabled category: F - Elapsed time: 15.454s
Disabled category: R - Elapsed time: 6.865s
Disabled category: C - Elapsed time: 15.518s
Disabled category: W - Elapsed time: 15.054s
Disabled category: I - Elapsed time: 15.827s

The reason we also have similar speedups in the second time is that if none of the messages a checker has is enabled, the whole checker will be ignored - this is done without relying on ``check_messages``, but by inspecting the ``msgs`` attribute directly.

We can see that the difference between the two runs is marginal. As stated above a lot of ``@check_messages`` decorator are missing actually emittable messages this callback has, so I would expect the differences to be even less if we would put in the effort to fix the ``check_messages`` calls.

If we want to aim for performance I guess it would be more promising to write the ``only_required_for`` decorator in such a way it can be applied to any function/method. That way we could determine the most expensive subfunctions/checks by profiling and then make them ``skippable``.

For completeness, here the quick'n'dirty script:
```python
import time
from contextlib import suppress
from pathlib import Path

from pylint.lint import Run

if __name__ == "__main__":
    categories = ["E", "F", "R", "C", "W", "I"]
    for category in categories:
        start = time.perf_counter()
        with suppress(SystemExit):
            Run(
                [
                    str(Path(__file__).parent.parent / "pylint"),
                    "--enable=all",
                    f"--disable={category}",
                    "--output-format=pylint.testutils.MinimalTestReporter",
                ]
            )
        end = time.perf_counter()
        print(f"Disabled category: {category} - Elapsed time: {end-start:0.3f}s")
```

Hmm, since the documentation project is likely to find all these issues it is very likely that all `check_messages` call will be correct after that project has finished.

What about creating a `must_always_be_checked` decorator that we can add to `visit_` or `leave_` calls with side-effects? That way we don't accidentally add the decorator to functions that don't have them but keep the possible performance benefits that these can create. The speed up for disabling `R` is quite significant.

The speed-up when running with ``--disable=R`` comes mainly from disabling whole checkers (namely ``SimilarChecker``):

> The reason we also have similar speedups in the second time is that if none of the messages a checker has is enabled, the whole checker will be ignored - this is done without relying on check_messages, but by inspecting the msgs attribute directly.

Can you give an example for ``must_always_be_checked``? Would this be an alternative to ``only_required_for``/``check_messages``, or an addition? 
> Can you give an example for `must_always_be_checked`? Would this be an alternative to `only_required_for`/`check_messages`, or an addition?

> 5. Applying the decorator to a callback that not only emits messages but also does other things can have nasty side effects (false positives, false negatives, crashes)

This was mostly in relation to the above point. I think that in the `NamesConsumer` there might be `visits` that set up stuff for later?
There might be a benefit to separating messages inside checker to reduce this complexity. For example the "basic" checker is dispatched between multiple classes so it seems to be possible.

https://github.com/PyCQA/pylint/blob/main/pylint/checkers/base/basic_checker.py#L36
https://github.com/PyCQA/pylint/blob/main/pylint/checkers/base/basic_checker.py#L105
https://github.com/PyCQA/pylint/blob/main/pylint/checkers/base/comparison_checker.py#L24

There is a benefit with doing checks only once instead of doing it in each class but if it's possible to separate them, we're creating a mess by putting two independent check in the same ``visit_*``. Say ``visit_compare`` in the comparison checker, could probably be in multiple class because check nan, singleton and literal comparison looks independent (https://github.com/PyCQA/pylint/blob/main/pylint/checkers/base/comparison_checker.py#L245)
A counterpoint to that is that many of these `visit_` calls will then infer values. Depending on the order and difficulty of inference these calls might fall outside of the cache and become rather expensive if separated into different classes.

I explored passing a pre-inferred value to `visit_` calls but never followed up on it. 
> There is a benefit with doing checks only once instead of doing it in each class but if it's possible to separate them, we're creating a mess by putting two independent check in the same ``visit_*``

I agree, bloating the ``visit_*`` method itself is not good for maintainability.
But in this case I would prefer splitting the checks for each message in subfunctions, as can bee seen in the first three lines of the ``visit_compare`` you mentioned.

This, of course, makes it harder to keep track of all messages that can be possibly emitted by this ``visit_*`` method.
If we want to keep ``check_messages`` or some renamed variant of it for possible performance gains, I would prefer to make it work on any method of a checker, not just ``visit_*`` or ``leave_*``. And then apply it only to the subfunctions, and not the ``visit_*`` callback itself.


> For example the "basic" checker is dispatched between multiple classes so it seems to be possible.

I am confused on what the benefit of this ``_BasicChecker`` class is besides not having to repeat the checker ``name`` and ``__implements__`` in each subclass. 
> I am confused on what the benefit of this _BasicChecker class is besides not having to repeat the checker name and __implements__ in each subclass.

Apparently nothing else, I opened a MR to check with the full test suites (#6091).
Should we vote for the future of ``check_messages``?

- ❤️ leave it as is, just check and correct the usage of it across the codebase
- 🚀 rename it to ``only_required_for`` and check and correct usage of it
- 🎉 remove its usage entirely and issue ``DeprecationWarning`` if it is applied

Maybe also @cdce8p and @jacobtylerwalls want to cast their vote on this?
Personally I am torn between option 2 and 3 because the performance benefit seems marginal, but I'm still a bit more in favour of renaming. 
Are we sure the renaming (and thus `DeprecationWarning` on the old name) are worth the hassle?
Oh, it's public? I didn't realize that. Is it documented anywhere? I didn't realize we were talking about deprecation warnings.
We need some sort of definition of the public API footprint. I wouldn't know where to get that info.
> Oh, it's public? I didn't realize that. Is it documented anywhere? I didn't realize we were talking about deprecation warnings.

At this point I don't know: but it is an non-underscored function in `utils`. I would consider it highly likely that some (old) plugin has imported it. Especially since most plugins will likely just copy a basic checker from `pylint` when they start working on their checkers. It's likely that they just copied this as well.
> It's likely that they just copied this as well.

Yep: https://sourcegraph.com/github.com/chromium/chromium/-/blob/third_party/pylint/pylint/checkers/python3.py

Alright. I'm changing my vote to "let's document this in the development guide somewhere"
I'm voting that as well. I do think the suggested name is much better, but I am not sure if the hassle of changing it is worth it.
> We need some sort of definition of the public API footprint.

The public API is/was undocumented so it's always a guess as to how much use there is in downstream libraries. For example confidences could be refactored to an ordered enum and save us a lot of trouble but I **suppose** it's used somewhere and we can't just do that. Creating such a document would be nice but we'll still need to guess what was public API because we could be wrong and pointing to this document when we break a widely used API (https://github.com/PyCQA/pylint/issues/4399) is not going to save us :) 


>  > It's likely that they just copied this as well.

> Yep: https://sourcegraph.com/github.com/chromium/chromium/-/blob/third_party/pylint/pylint/checkers/python3.py

The python3 checker is not based on pylint, it's pylint's code directly (we removed it from pylint a while ago). The doc do not talk about the decorator : https://pylint.pycqa.org/en/latest/how_tos/custom_checkers.html, nor does the examples uses it : https://github.com/PyCQA/pylint/tree/main/examples. Of course it's still possible that someone at some point copy pasted one of our checker with the decorator in it so we should be safe about it.

The documentation project for each message as shown that there are a lot of issue with this decorator, maybe 25% of message don't work alone if other messages are disabled. I'm not sure keeping the name is a good idea when it creates so much hard to debug issues in our own code (before @DudeNr33 had the good idea to check what it actually does 😄). It's also going to create problems in downstream code where it's used imo.

So I think we should rename it to ``only_required_for``, check correct usage in our code, and deprecate ``check_messages`` with a warning explaining why it's a dangerous decorator. Then we remove ``check_messages`` in 3.0. It's a lot of work but probably less than having to explain it to newcomers or downstream library maintainers and debugging the issues it creates.
Sorry for being so indecisive! A self-documenting name is probably less effort than writing a hard-to-understand paragraph people might not find. So let's do the rename/deprecation warnings 👍🏻 
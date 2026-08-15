Thanks for the report, this is definitely something we should be able to fix.
Hi. It seems to work when it's on the same line but not globally (which could be useful but I didn't found anything on the documentation). So I have to do:
`# pylint: disable=bad-option-value,useless-object-inheritance`
If I later want to use another option, I have to repeat it again:
`# pylint: disable=bad-option-value,consider-using-sys-exit`
My (unwarranted) two cents: I don't quite see the point of allowing to run different versions of pylint on the same code base.

Different versions of pylint are likely to yield different warnings, because checks are added (and sometimes removed) between versions, and bugs (such as false positives) are fixed. So if your teammate does not run the same version as you do, they may have a "perfect pylint score", while your version gets warnings. Surely you'd rather have a reproducible output, and the best way to achieve that is to warrant a specific version of pylint across the team and your CI environment.
@dbaty Running different versions of pylint helps when porting code from Python2 to Python3
So, what's the status ?
Dropping support for an option, and also having a bad-option-value be an error makes pylint not backwards compatible. It looks like you expect everyone to be able to atomically update their pylint version *and* all of their code annotations in all of their environments at the same time.

I maintain packages supporting python 2.7, 3.4-3.10, and since pylint no longer supports all of those, I'm forced to use older versions of pylint in some environments, which now are not compatible with the latest. I don't know if this is a new behavior or has always been this way, but today was the first time I've had any problem with pylint , and am going to have to disable it in CI now.

@jacobtylerwalls I have a fix, but it requires changing the signature of `PyLinter.process_tokens`. Do we consider that public API?

The issue is that we need to call `file_state.collect_block_lines` to expand a block-level disable over its respective block. This can only be done with access to the `ast` node. Changing `PyLinter.disable` to have access to `node` seems like a very breaking change, although it would be much better to do the expansion immediately upon disabling instead of somewhere later.
My approach does it every time we find a `disable` pragma. We can explore whether we can do something like `collect_block_lines_one_message` instead of iterating over the complete `_module_msgs_state` every time. Still, whatever we do we require access to `node` inside of `process_tokens`.
How likely is it that plugins are calling `PyLinter.process_tokens`?

```diff
diff --git a/pylint/lint/pylinter.py b/pylint/lint/pylinter.py
index 7c40f4bf2..4b00ba5ac 100644
--- a/pylint/lint/pylinter.py
+++ b/pylint/lint/pylinter.py
@@ -527,7 +527,9 @@ class PyLinter(
     # block level option handling #############################################
     # see func_block_disable_msg.py test case for expected behaviour
 
-    def process_tokens(self, tokens: list[tokenize.TokenInfo]) -> None:
+    def process_tokens(
+        self, tokens: list[tokenize.TokenInfo], node: nodes.Module
+    ) -> None:
         """Process tokens from the current module to search for module/block level
         options.
         """
@@ -595,6 +597,7 @@ class PyLinter(
                             l_start -= 1
                         try:
                             meth(msgid, "module", l_start)
+                            self.file_state.collect_block_lines(self.msgs_store, node)
                         except exceptions.UnknownMessageError:
                             msg = f"{pragma_repr.action}. Don't recognize message {msgid}."
                             self.add_message(
@@ -1043,7 +1046,7 @@ class PyLinter(
             # assert astroid.file.endswith('.py')
             # invoke ITokenChecker interface on self to fetch module/block
             # level options
-            self.process_tokens(tokens)
+            self.process_tokens(tokens, node)
             if self._ignore_file:
                 return False
             # walk ast to collect line numbers
diff --git a/tests/functional/b/bad_option_value_disable.py b/tests/functional/b/bad_option_value_disable.py
new file mode 100644
index 000000000..cde604411
--- /dev/null
+++ b/tests/functional/b/bad_option_value_disable.py
@@ -0,0 +1,6 @@
+"""Tests for the disabling of bad-option-value."""
+# pylint: disable=invalid-name
+
+# pylint: disable=bad-option-value
+
+var = 1  # pylint: disable=a-removed-option
```
The PyLinter is pylint's internal god class, I think if we don't dare to modify it it's a problem. On the other hand, it might be possible to make the node ``Optional`` with a default value of ``None`` and raise a deprecation warning if the node is ``None`` without too much hassle ?

```diff
- self.file_state.collect_block_lines(self.msgs_store, node)
+ if node is not None:
+     self.file_state.collect_block_lines(self.msgs_store, node)
+ else:
+     warnings.warn(" process_tokens... deprecation... 3.0.. bad option value won't be disablable...")
Yeah, just making it optional and immediately deprecating it sounds good. Let's add a test for a disabling a message by ID also.
I found some issue while working on this so it will take a little longer.

However, would you guys be okay with one refactor before this to create a `_MessageStateHandler`. I would move all methods like `disable`, `enable`, `set_message_state` etc into this class. Similar to how we moved some of the `PyLinter` stuff to `_ArgumentsManager`. I know we had something similar with `MessageHandlerMixIn` previously, but the issue was that that class was always mixed with `PyLinter` but `mypy` didn't know this.
There are two main benefits:
1) Clean up of `PyLinter` and its file
2) We no longer need to inherit from `BaseTokenChecker`. This is better as `pylint` will rightfully complain about `process_tokens` signature not having `node` as argument. If we keep inheriting we will need to keep giving a default value, which is something we want to avoid in the future.

For now I would only:
1) Create `_MessageStateHandler` and let `PyLinter` inherit from it.
2) Make `PyLinter` a `BaseChecker` and move `process_tokens` to `_MessageStateHandler`.
3) Fix the issue in this issue.

Edit: A preparing PR has been opened with https://github.com/PyCQA/pylint/pull/6537.
Before I look closer to come up with an opinion, I just remember we have #5156, so we should keep it in mind or close it.
I think #5156 is compatible with the proposition Daniel made, it can be a first step as it's better to inherit from ``BaseChecker`` than from ``BaseTokenChecker``.
@DanielNoord sounds good to me!
Well, the refactor turned out to be rather pointless as I ran into multiple subtle regressions with my first approach.

I'm now looking into a different solution: modifying `FileState` to always have access to the relevant `Module` and then expanding pragma's whenever we encounter them. However, this is also proving tricky... I can see why this issue has remained open for so long.
Thank you for looking into it!
Maybe a setting is enough?
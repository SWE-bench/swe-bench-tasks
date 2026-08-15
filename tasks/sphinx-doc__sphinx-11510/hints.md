Unfortunately, the `source-read` event does not support the `include` directive. So it will not be emitted on inclusion.

>Note that the dumping docname and source[0] shows that the function actually gets called for something-to-include.rst file and its content is correctly replaced in source[0], it just does not make it to the final HTML file for some reason.

You can see the result of the replacement in `something-to-include.html` instead of `index.html`. The source file was processed twice, as a source file, and as an included file. The event you saw is the emitted for the first one.
This should at the very least be documented so users don't expect it to work like I did.

I understand "wontfix" as "this is working as intended", is there any technical reason behind this choice? Basically, is this something that can be implemented/fixed in future versions or is it an active and deliberate choice that it'll never be supported?
Hello.

Is there any workaround to solve this? Maybe hooking the include action as with source-read?? 
> Hello.
> 
> Is there any workaround to solve this? Maybe hooking the include action as with source-read??

I spent the last two days trying to use the `source-read` event to replace the image locations for figure and images.  I found this obscure, open ticket, saying it is not possible using Sphinx API? 

Pretty old ticket, it is not clear from the response by @tk0miya if this a bug, or what should be done instead.  This seems like a pretty basic use case for the Sphinx API (i.e., search/replace text using the API)
AFAICT, this is the intended behaviour. As they said:

> The source file was processed twice, as a source file, and as an included file. The event you saw is the emitted for the first one.

IIRC, the `source-read` event is fired at an early stage of the build, way before the directives are actually processed. In particular, we have no idea that there is an `include` directive (and we should not parse the source at that time). In addition, the content being included is only read when the directive is executed and not before. 

If you want the file being included via the `include` directive to be processed by the `source-read` event, you need to modify the `include` directive. However, the Sphinx `include` directive is only a wrapper around the docutils `include` directive so the work behind is tricky.

Instead of using `&REPLACE;`, I would suggest you to use substitution constructions and putting them in an `rst_prolog` instead. For instance,

```python
rst_prolog = """
.. |mine| replace:: not yours
"""
```

and then, in the desired document:

```rst
This document is |mine|.
```

--- 

For a more generic way, you'll need to dig up more. Here are some hacky ideas:

- Use a template file (say `a.tpl`) and write something like `[[a.tpl]]`. When reading the file, create a file `a.out` from `a.tpl` and replace `[[a.tpl]]` by `.. include:: a.out`. 
- Alternatively, add a post-transformation acting on the nodes being generated in order to replace the content waiting to be replaced. This can be done by changing the `include` directive and post-processing the nodes that were just created for instance.
Here is a solution, that fixes the underlying problem in Sphinx, using an extension:

```python
"""Extension to fix issues in the built-in include directive."""

import docutils.statemachine

# Provide fixes for Sphinx `include` directive, which doesn't support Sphinx's 
# source-read event.
# Fortunately the Include directive ultimately calls StateMachine.insert_input,
# for rst text and this is the only use of that function.  So we monkey-patch!


def setup(app):
    og_insert_input = docutils.statemachine.StateMachine.insert_input

    def my_insert_input(self, include_lines, path):
        # first we need to combine the lines back into text so we can send it with the source-read
        # event:
        text = "\n".join(include_lines)
        # emit "source-read" event
        arg = [text]
        app.env.events.emit("source-read", path, arg)
        text = arg[0]
        # split into lines again:
        include_lines = text.splitlines()
        # call the original function:
        og_insert_input(self, include_lines, path)

    # inject our patched function
    docutils.statemachine.StateMachine.insert_input = my_insert_input

    return {
        "version": "0.0.1",
        "parallel_read_safe": True,
        "parallel_write_safe": True,
    }
```
Now, I'm willing to contribute a proper patch to Sphinx (subclassing `docutils.statematchine.StateMachine` to extend the `insert_input` function).  But I'm not going to waste time on that if Sphinx maintainers are not interested in getting this problem addressed.  Admittedly, my fix-via-extension above works well enough and works around the issue.
This extension enables me to set conditionals on table rows. Yay!
> Here is a solution, that fixes the underlying problem in Sphinx, using an extension:
> 
> ```python
> """Extension to fix issues in the built-in include directive."""
> 
> import docutils.statemachine
> 
> # Provide fixes for Sphinx `include` directive, which doesn't support Sphinx's 
> # source-read event.
> # Fortunately the Include directive ultimately calls StateMachine.insert_input,
> # for rst text and this is the only use of that function.  So we monkey-patch!
> 
> 
> def setup(app):
>     og_insert_input = docutils.statemachine.StateMachine.insert_input
> 
>     def my_insert_input(self, include_lines, path):
>         # first we need to combine the lines back into text so we can send it with the source-read
>         # event:
>         text = "\n".join(include_lines)
>         # emit "source-read" event
>         arg = [text]
>         app.env.events.emit("source-read", path, arg)
>         text = arg[0]
>         # split into lines again:
>         include_lines = text.splitlines()
>         # call the original function:
>         og_insert_input(self, include_lines, path)
> 
>     # inject our patched function
>     docutils.statemachine.StateMachine.insert_input = my_insert_input
> 
>     return {
>         "version": "0.0.1",
>         "parallel_read_safe": True,
>         "parallel_write_safe": True,
>     }
> ```
> 
> Now, I'm willing to contribute a proper patch to Sphinx (subclassing `docutils.statematchine.StateMachine` to extend the `insert_input` function). But I'm not going to waste time on that if Sphinx maintainers are not interested in getting this problem addressed. Admittedly, my fix-via-extension above works well enough and works around the issue.

Wow! that's a great plugin. Thanks for sharing!!
One more thing, this issue should be named "**source-read event is not emitted for included rst files**" - that is truly the issue at play here.  

What my patch does is inject code into the `insert_input` function so that it emits a proper "source-read" event for the rst text that is about to be included into the host document.  This issue has been in Sphinx from the beginning and a few bugs have been created for it.  Based on the responses to those bugs I have this tingling spider-sense that not everybody understands what the underlying problem really is, but I could be wrong about that.  My spider-sense isn't as good as Peter Parker's :wink:
I was worked around the problem by eliminating all include statements in our documentation.  I am using TOC solely instead.  Probably best practice anyway.
@halldorfannar please could you convert your patch into a PR?

A
Absolutely, @AA-Turner. I will start that work today.
Unfortunately, the `source-read` event does not support the `include` directive. So it will not be emitted on inclusion.

>Note that the dumping docname and source[0] shows that the function actually gets called for something-to-include.rst file and its content is correctly replaced in source[0], it just does not make it to the final HTML file for some reason.

You can see the result of the replacement in `something-to-include.html` instead of `index.html`. The source file was processed twice, as a source file, and as an included file. The event you saw is the emitted for the first one.
This should at the very least be documented so users don't expect it to work like I did.

I understand "wontfix" as "this is working as intended", is there any technical reason behind this choice? Basically, is this something that can be implemented/fixed in future versions or is it an active and deliberate choice that it'll never be supported?
Hello.

Is there any workaround to solve this? Maybe hooking the include action as with source-read?? 
> Hello.
> 
> Is there any workaround to solve this? Maybe hooking the include action as with source-read??

I spent the last two days trying to use the `source-read` event to replace the image locations for figure and images.  I found this obscure, open ticket, saying it is not possible using Sphinx API? 

Pretty old ticket, it is not clear from the response by @tk0miya if this a bug, or what should be done instead.  This seems like a pretty basic use case for the Sphinx API (i.e., search/replace text using the API)
AFAICT, this is the intended behaviour. As they said:

> The source file was processed twice, as a source file, and as an included file. The event you saw is the emitted for the first one.

IIRC, the `source-read` event is fired at an early stage of the build, way before the directives are actually processed. In particular, we have no idea that there is an `include` directive (and we should not parse the source at that time). In addition, the content being included is only read when the directive is executed and not before. 

If you want the file being included via the `include` directive to be processed by the `source-read` event, you need to modify the `include` directive. However, the Sphinx `include` directive is only a wrapper around the docutils `include` directive so the work behind is tricky.

Instead of using `&REPLACE;`, I would suggest you to use substitution constructions and putting them in an `rst_prolog` instead. For instance,

```python
rst_prolog = """
.. |mine| replace:: not yours
"""
```

and then, in the desired document:

```rst
This document is |mine|.
```

--- 

For a more generic way, you'll need to dig up more. Here are some hacky ideas:

- Use a template file (say `a.tpl`) and write something like `[[a.tpl]]`. When reading the file, create a file `a.out` from `a.tpl` and replace `[[a.tpl]]` by `.. include:: a.out`. 
- Alternatively, add a post-transformation acting on the nodes being generated in order to replace the content waiting to be replaced. This can be done by changing the `include` directive and post-processing the nodes that were just created for instance.
Here is a solution, that fixes the underlying problem in Sphinx, using an extension:

```python
"""Extension to fix issues in the built-in include directive."""

import docutils.statemachine

# Provide fixes for Sphinx `include` directive, which doesn't support Sphinx's 
# source-read event.
# Fortunately the Include directive ultimately calls StateMachine.insert_input,
# for rst text and this is the only use of that function.  So we monkey-patch!


def setup(app):
    og_insert_input = docutils.statemachine.StateMachine.insert_input

    def my_insert_input(self, include_lines, path):
        # first we need to combine the lines back into text so we can send it with the source-read
        # event:
        text = "\n".join(include_lines)
        # emit "source-read" event
        arg = [text]
        app.env.events.emit("source-read", path, arg)
        text = arg[0]
        # split into lines again:
        include_lines = text.splitlines()
        # call the original function:
        og_insert_input(self, include_lines, path)

    # inject our patched function
    docutils.statemachine.StateMachine.insert_input = my_insert_input

    return {
        "version": "0.0.1",
        "parallel_read_safe": True,
        "parallel_write_safe": True,
    }
```
Now, I'm willing to contribute a proper patch to Sphinx (subclassing `docutils.statematchine.StateMachine` to extend the `insert_input` function).  But I'm not going to waste time on that if Sphinx maintainers are not interested in getting this problem addressed.  Admittedly, my fix-via-extension above works well enough and works around the issue.
This extension enables me to set conditionals on table rows. Yay!
> Here is a solution, that fixes the underlying problem in Sphinx, using an extension:
> 
> ```python
> """Extension to fix issues in the built-in include directive."""
> 
> import docutils.statemachine
> 
> # Provide fixes for Sphinx `include` directive, which doesn't support Sphinx's 
> # source-read event.
> # Fortunately the Include directive ultimately calls StateMachine.insert_input,
> # for rst text and this is the only use of that function.  So we monkey-patch!
> 
> 
> def setup(app):
>     og_insert_input = docutils.statemachine.StateMachine.insert_input
> 
>     def my_insert_input(self, include_lines, path):
>         # first we need to combine the lines back into text so we can send it with the source-read
>         # event:
>         text = "\n".join(include_lines)
>         # emit "source-read" event
>         arg = [text]
>         app.env.events.emit("source-read", path, arg)
>         text = arg[0]
>         # split into lines again:
>         include_lines = text.splitlines()
>         # call the original function:
>         og_insert_input(self, include_lines, path)
> 
>     # inject our patched function
>     docutils.statemachine.StateMachine.insert_input = my_insert_input
> 
>     return {
>         "version": "0.0.1",
>         "parallel_read_safe": True,
>         "parallel_write_safe": True,
>     }
> ```
> 
> Now, I'm willing to contribute a proper patch to Sphinx (subclassing `docutils.statematchine.StateMachine` to extend the `insert_input` function). But I'm not going to waste time on that if Sphinx maintainers are not interested in getting this problem addressed. Admittedly, my fix-via-extension above works well enough and works around the issue.

Wow! that's a great plugin. Thanks for sharing!!
One more thing, this issue should be named "**source-read event is not emitted for included rst files**" - that is truly the issue at play here.  

What my patch does is inject code into the `insert_input` function so that it emits a proper "source-read" event for the rst text that is about to be included into the host document.  This issue has been in Sphinx from the beginning and a few bugs have been created for it.  Based on the responses to those bugs I have this tingling spider-sense that not everybody understands what the underlying problem really is, but I could be wrong about that.  My spider-sense isn't as good as Peter Parker's :wink:
I was worked around the problem by eliminating all include statements in our documentation.  I am using TOC solely instead.  Probably best practice anyway.
@halldorfannar please could you convert your patch into a PR?

A
Absolutely, @AA-Turner. I will start that work today.
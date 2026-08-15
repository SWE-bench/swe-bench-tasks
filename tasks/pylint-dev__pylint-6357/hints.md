Unfortunately, I cannot reproduce the error. Please make sure the indentation is correct. `AstroidSyntaxError` is usually emitted if the Python AST parsing failed.
The syntax is correct (Python can execute the code just fine).

Did you call pylint with `--ignore-imports=y`?
for some reason, `lines` in https://github.com/PyCQA/pylint/blob/85a480427c0f14dba9e26d56286b0a370057e792/pylint/checkers/similar.py#L566-L567 is only `['#!/usr/bin/python\n', 'import os\n', '\n', 'def bug():\n']` which indeed *is* invalid code.

It probably gets swallowed here:
https://github.com/PyCQA/pylint/blob/85a480427c0f14dba9e26d56286b0a370057e792/pylint/checkers/similar.py#L368-L369
I can reproduce this with your specific versions of Pylint & astroid.
It doesn't occur for:
```
pylint 2.14.0-dev0
astroid 2.11.2
Python 3.10.0b2 (v3.10.0b2:317314165a, May 31 2021, 10:02:22) [Clang 12.0.5 (clang-1205.0.22.9)]
```
Right, upgrading `pylint` to latest git (47e168cf607e2069b103fc466edfe1c6522e2fb2) does fix it.
I was able to reproduce it now. Like @mbyrnepr2 said, this is already fixed in `main`. In particular #6271 seems to be the PR which resolved it. Tbh though, I'm not quite sure why.

Maybe you have an idea @DanielNoord? It seems to be related to the `--ignore-imports=y` option.
Would we be able to backport the change?
No, sorry! I have no immediate hunch for what could have been the fix (or previous bug)/

The only thing I can think of is the commenting of `linter.load_command_line_configuration`. Especially since the `ignore-imports` comes from the CLI. The way `Similar` (of which the options originates) interacts with the configuration parsing is quite intricate because it also has to do it semi-standalone. I worry I might have broken something while working on the transition that wasn't caught by our testsuite.
It might be worth checking if we can also reproduce this with `ignore-imports` in a configuration file. If not, then we could add a notice about this in the release notes of `2.13.6`.

Sorry guys! I hoped to avoid this! 😓 
> Sorry guys! I hoped to avoid this!

Don't worry, as we say in some python packaging circles it's impossible to migrate to argparse without breaking a few eggs.
@evgeni Have you checked if the problem exists when using a configuration file as well? If not I'd say we can close this issue and (sadly) accept that this might be a bug in `2.13.6` and any other `2.13.x`...
Same thing with a config:

```console
% cat pylintrc
[MASTER]
ignore-imports=y

% python -m pylint ./l2.py
************* Module l2
l2.py:1:0: F0002: l2.py: Fatal error while checking 'l2.py'. Please open an issue in our bug tracker so we address this. There is a pre-filled template that you can use in '/home/evgeni/.cache/pylint/pylint-crash-2022-04-15-09.txt'. (astroid-error)
```
😢 

Sorry, I don't really have an easy solution here. Especially since this might have happened somewhere in the middle of the 30+ PRs that were necessary to transition from `optparse` to `argparse`... The only thing I can do is work extra hard to get `2.14` out sooner and have it work again 😄 
🤗

No worries, I can just pin to <2.13 for now.

For the mighty search engines: on Python 3.8 the error reads `SyntaxError: unexpected EOF while parsing`, the rest is identical :)
Btw, `2.13.0` should work. We didn't touch the configuration handling until after `.0`!
Nope, this is failing for me with

```console
% python -m pylint --version
pylint 2.13.0
astroid 2.11.2
Python 3.10.4 (main, Mar 25 2022, 00:00:00) [GCC 11.2.1 2022012
7 (Red Hat 11.2.1-9)]
```
Then we might have actually fixed a bug we didn't know about by moving to `argparse`...

I don't know any more 😅 

I'm going to keep this issue open for visibility and close it as we release `2.14`. Thanks for helping triaging this and sorry for not being able to give a better solution!
I was curious, so I bisected it. : D

We have, unfortunately, two bugs where the second bug silenced the crash aspect of the first one.

Bug 1: 4ca885fd8c35e6781a359cda0e4de2c0910973b6
Block disables can be used on function defs. So by creating the functionality of block disables for `duplicate-code`, everything under the `def` line is empty, which will crash with `AstroidError` when parsed in `checkers.similar.stripped_lines()`.

Bug 2: 03cfbf3df1d20ba1bfd445c59f18c906e8dd8a62
This silenced the other bug by just not respecting `ignore-imports=y`. Place a breakpoint before if `if ignore_imports or ignore_signatures:` in `checkers.similar.stripped_lines()` and see that `ignore_imports` is now False. Something to do with SimilarChecker registering options. I'll open a separate issue for that for 2.14. We can leave this issue open for the crash in 2.13.6.
![escalated](https://i.kym-cdn.com/photos/images/newsfeed/000/353/279/e31.jpg)

Originally I thought this was my odd codebase that was tripping over pylint and wanted to shrug it off…
:-) we love testers! second issue extracted into #6350 so we can make sure to do it. thanks for getting in touch!
@jacobtylerwalls What do you think would the best way to solve this? I was thinking maybe add an `...` to `lines` for every disable we encounter, but then `Similar` might start bugging users about duplicate `...`?
I'm testing a patch that inserts ": ..." so that `def a():  # pylint: disable=blah\n` becomes `def a(): ...  # pylint: disable=blah\n` etc
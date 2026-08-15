Agreed, it's probably the option I use most which doesn't have a shortcut.

Both `-c` and `-o` are taken. I guess `-n` (as in "no action", compare `-n`/`--dry-run` for e.g. `git clean`) could work? 

Maybe `--co` (for either "**co**llect" or "**c**ollect **o**nly), similar to other two-character shortcuts we already have (`--sw`, `--lf`, `--ff`, `--nf`)?
I like `--co`, and it doesn't seem to be used by any plugins as far as I can search:

https://github.com/search?utf8=%E2%9C%93&q=--co+language%3APython+pytest+language%3APython+language%3APython&type=Code&ref=advsearch&l=Python&l=Python
> I find myself needing to run `--collect-only` very often and that cli argument is a very long to type one.

Just out of curiosity: Why?  (i.e. what's your use case?)

+0 for `--co`.

But in general you can easily also have an alias "alias pco='pytest --collect-only'" - (or "alias pco='p --collect-only" if you have a shortcut for pytest already.. :))
I routinely use `--collect-only` when I switch to a different development branch or start working on a different area of our code base. I think `--co` is fine.
Agreed, it's probably the option I use most which doesn't have a shortcut.

Both `-c` and `-o` are taken. I guess `-n` (as in "no action", compare `-n`/`--dry-run` for e.g. `git clean`) could work? 

Maybe `--co` (for either "**co**llect" or "**c**ollect **o**nly), similar to other two-character shortcuts we already have (`--sw`, `--lf`, `--ff`, `--nf`)?
I like `--co`, and it doesn't seem to be used by any plugins as far as I can search:

https://github.com/search?utf8=%E2%9C%93&q=--co+language%3APython+pytest+language%3APython+language%3APython&type=Code&ref=advsearch&l=Python&l=Python
> I find myself needing to run `--collect-only` very often and that cli argument is a very long to type one.

Just out of curiosity: Why?  (i.e. what's your use case?)

+0 for `--co`.

But in general you can easily also have an alias "alias pco='pytest --collect-only'" - (or "alias pco='p --collect-only" if you have a shortcut for pytest already.. :))
I routinely use `--collect-only` when I switch to a different development branch or start working on a different area of our code base. I think `--co` is fine.
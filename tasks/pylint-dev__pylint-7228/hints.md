This doesn't seem like it is a `pylint` issue?

`re.compile("[\p{Han}a-z_]")` also raises normally. `\p` also isn't documented: https://docs.python.org/3/howto/regex.html
Is this a supported character?
I think this could be improved! Similar to the helpful output when passing an unrecognized option to Pylint, we could give a friendly output indicating that the regex pattern is invalid without the traceback; happy to put a MR together if you agree.
Thanks @mbyrnepr2 I did not even realize it was a crash that we had to fix before your comment.
@mbyrnepr2 I think in the above stacktrace on line 1858 makes the most sense.

We need to decide though if we continue to run the program. I think it makes sense to still quit. If we catch regex errors there and pass we will also "allow" ignore path regexes that don't work. I don't think we should do that.

Imo, incorrect regexes are a little different from other "incorrect" options, since there is little risk that they are valid on other interpreters or versions such as old messages etc. Therefore, I'd prefer to (cleanly) exit.
Indeed @DanielNoord I think we are on the same page regarding this point; I would also exit instead of passing if the regex is invalid. That line you mention, we can basically try/except on re.error and exit printing the details of the pattern which is invalid.
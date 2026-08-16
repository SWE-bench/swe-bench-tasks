I can't reproduce this, but this usually happens when the file itself is in some other format, rather than UTF-8, to begin with. Can you confirm it's definitely UTF-8 encoded? some tips here on how to check this: https://stackoverflow.com/questions/6947749/how-to-check-if-a-txt-file-is-in-ascii-or-utf-8-format-in-windows-environment
You'll probably need to explicitly set the encoding. SQLFluff defaults to using `autodetect`, which is implemented by the third-party `chardet` package, but it's not guaranteed to always do the right thing. If it misbehaves, we (SQLFluff) can't do anything about it.

```
# can either be autodetect or a valid encoding e.g. utf-8, utf-8-sig
encoding = autodetect
```

We'd like to hear back from you, but this issue is likely to be closed as "won't fix"/"can't fix"
I have confirmed that the file is indeed utf-8 encoded and I have explicitly set the encoding to utf-8 and retested with the same result.

After running `sqlfluff fix` I have seen the encoding change from utf-8 to western (Windows 1252)

EDIT: If i manually force the file to be utf-8 AFTER `sqlfluff fix`, it resolves the issue. Good to know, but not a sustainable solution
Did you set the encoding property in `.sqlfluff`? It does not appear in the `.sqlfluff` file you provided above.

Also, please provide a test SQL file. You only provided a comment, not a complete file. When I run `sqlfluff fix` on the file, I get:
```
(sqlfluff-3.9.1) ➜  sqlfluff git:(main) ✗ sqlfluff fix test.sql
==== finding fixable violations ====
==== no fixable linting violations found ====
All Finished 📜 🎉!
```
I did. The config file I provided does not contain it but I retested using your suggestion and had the same result
I tried the above on my Mac. The resulting file looked okay to me:
```
 - tariff scenario —> dm_tariff_scenario
```

What operating system are using? Windows? Mac? Linux?
I am on an intel mac with Montery 12.3.1

Are you able to run sqlfluff fix twice in succession? The first run is fine, its the second run that fails

(Depending on my editor, it may or may not show the offending character. ie vim shows it, sublime does not)

Yes, I can run it twice in succession. The first time, it fixes a bunch of things. The second time, no issues found. Partial output below.
```
L:  83 | P:  13 | L003 | Expected 0 indentations, found 3 [compared to line 01]
L:  84 | P:   5 | L003 | Expected 0 indentations, found 1 [compared to line 01]
==== fixing violations ====
72 fixable linting violations found
Are you sure you wish to attempt to fix these? [Y/n] ...
Attempting fixes...
Persisting Changes...
== [test.sql] PASS
Done. Please check your files to confirm.
All Finished 📜 🎉!
  [3 unfixable linting violations found]
(sqlfluff-3.9.1) ➜  sqlfluff git:(main) ✗ sqlfluff fix test.sql
==== finding fixable violations ====
==== no fixable linting violations found ====
All Finished 📜 🎉!
  [2 unfixable linting violations found]
```

I'm on an M1 Mac with Big Sur (11.5.2).

Very strange behavior:
* That I can't reproduce it on a similar machine
* That setting `encoding = utf-8` in `.sqlfluff` doesn't fix it.

Note that AFAIK, "encoding" is not a real property of most files file. It's a guess made when reading the file. Some file formats let you specify the encoding, but SQL is not one of them. Hence the need to use a package like `chardet`.

E.g. Python lets you do it with a special comment: https://stackoverflow.com/questions/6289474/working-with-utf-8-encoding-in-python-source
I just noticed interesting behavior. I ran with `-vv` to ensure my config and although I am specifying `encoding = utf-8`, the -vv output seems to suggest `autodetect`. It is honoring other config (like `dbt`). Attempting to see where I have gone wrong on my side

EDIT: for context on directory structure: 
```
.sqlfluff
./dbt/models/marts/core/file.sql
```
I am running sqlfluff from the same directory as the `.sqlfluff` file ie `sqlfluff fix dbt/models/marts/core/file.sql`
I've heard the behavior can become tricky if you have multiple .sqlfluff files in subdirectories, etc. Are you certain you added the setting in the correct section of the file? If you put it in the wrong place, it'll be ignored, and it'll use the default setting instead, which is autodetect.
it is at the top level 
```
[sqlfluff]
templater = dbt
dialect = snowflake
encoding = utf-8

...
```
as per your default configuration docs. There are no .sqlfluff files in sub folders in that directory
@barrywhart Okay... so if I specify `--encoding utf-8` as a CLI command I am able to fix the file with no issue!! Thank you for helping with that!

I am unsure why it is not honoring that config however. Is there a way you would recommend debugging this issue from my side? We use this both as a CLI tool and as a pre-commit - so we are able to use the `--encoding` option explicitly, but it provides peace of mind to know why it _seems_ to not honor specific configs

I have changed other configs (ie adding an `excluded_rule`) and it IS honoring that (with no other changes to how i am running it)

Also super appreciate all the help :) 
Let me look into it later (probably in the next day or two). Not many people use this option, so I'd like to double check that it's being read correctly from config.
awesome! I appreciate it @barrywhart (and @tunetheweb )!

We, as an organization, are investing in SQLFluff as our production linter and we appreciate your support!
Thanks for the kind words. It's exciting to us seeing the project catching on. I've been involved with the project since late 2019, and I'm proud of the progress it's made. It seems to be becoming pretty mainstream now. One reason I've stayed involved is, how often do you get to help invent a fundamental new industry tool? 😊

BTW, feel free to delete your example SQL from the issue. It seems like we may not need it anymore?
Exactly! I have been loosely following this project for the past year and have been pushing to use it widely for a while! We adopted DBT and, since SQLFluff interacts well with DBT, we got the buy-in to invest :)

And yes I will delete the SQL!

Please let me know what you find relating to the encoding configuration! I am continuing to fiddle from my side!
I'm seeing the same issue -- seems that the `encoding` setting in `.sqlfluff` is not being read correctly:
```
[sqlfluff]
encoding = utf-8
```

We have automated tests for encoding, but they are lower-level tests (i.e. they exercise internal code directly, not reading encoding from `.sqlfluff`).

I'll take a closer look. Presumably, this should be easy to fix.
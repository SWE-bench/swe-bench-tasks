Enable quiet mode/no-verbose in CLI for use in pre-commit hook
There seems to be only an option to increase the level of verbosity when using SQLFluff [CLI](https://docs.sqlfluff.com/en/stable/cli.html), not to limit it further.

It would be great to have an option to further limit the amount of prints when running `sqlfluff fix`, especially in combination with deployment using a pre-commit hook. For example, only print the return status and the number of fixes applied, similar to how it is when using `black` in a pre-commit hook:
![image](https://user-images.githubusercontent.com/10177212/140480676-dc98d00b-4383-44f2-bb90-3301a6eedec2.png)

This hides the potentially long list of fixes that are being applied to the SQL files, which can get quite verbose.

I get a dbt-related error -- can you provide your project file as well? Also, what operating system are you running this on? I tested a simplified (non-dbt) version of your file on my Mac, and it worked okay.

```
dbt.exceptions.DbtProjectError: Runtime Error
  no dbt_project.yml found at expected path /Users/bhart/dev/sqlfluff/dbt_project.yml
```
Never mind the questions above -- I managed to reproduce the error in a sample dbt project. Taking a look now...
@Tumble17: Have you tried setting the `encoding` parameter in `.sqlfluff`? Do you know what encoding you're using? The default is `autodetect`, and SQLFluff "thinks" the file uses "Windows-1252" encoding, which I assume is incorrect -- that's why SQLFluff is unable to write out the updated file.
I added this line to the first section of your `.sqlfluff`, and now it seems to work. I'll look into changing the behavior of `sqlfluff fix` so it doesn't erase the file when it fails.

```
encoding = utf-8
```
Does L027 use `SelectCrawler`? This sounds like an issue where it may be helpful.

Related: Rules that use `SelectCrawler` may be good candidates to benefit from setting `recurse_into` to `False`. (Setting the flag is just a start. This also requires reworking the rule code, hopefully no more than 1-2 hours of work.)
Answering my own question: It does not seem to use `SelectCrawler`. Rules that currently use it:
* L025
* L026
* L044
* L045

From a quick look at the YML test files for each of these rules, I suggest L044 would be the best one to review in terms of handling similar requirements. Look for test cases that mention "subquery".
I think a very similar fix to that implemented in this [PR for L028](https://github.com/sqlfluff/sqlfluff/pull/3156) will also work here. In particular, notice the code that looks at `query.parent` to find tables that are "visible" to a particular query.

https://github.com/sqlfluff/sqlfluff/blob/main/src/sqlfluff/rules/L028.py#L108L114
Related to #3380, possibly duplicate
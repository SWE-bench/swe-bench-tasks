I like your suggestion. I would suggest a slightly different wording: raise TypeError( "Cannot encode None for key '%s' as POST data. Did you mean " "to pass an empty string or omit the value?" % key )
I agree with Markus' suggestion. Can you create PR via GitHub?
I will change the wording and create a PR. I have one more question, can I use f-strings since this is going into master? I cloned the repo and tried to run the tests in a Python 3.5 environment but it wouldn't let me.
Django 3.0 supports Python 3.6+, nevertheless please don't use f-strings (see #29988).
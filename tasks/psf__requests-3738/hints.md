I should note that we have had this conversation with the docker-py folks before: see #1879.

Ultimately, there is a problem with how much people want us to understand URLs for non-standard HTTP schemes. People would like us to understand them enough to add query parameters, but not so much that we look for a hostname to internationalize.

I am as conflicted as I was three years ago.
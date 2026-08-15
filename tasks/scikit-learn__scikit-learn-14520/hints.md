Indeed, as far as I can tell, the `copy` parameter can be deprecated and marked for removal in 2 versions in `TfidfVectorizer`. We never modify the string input inplace.

The only place it's useful in vectoirizers is `TfidfTransformer`.

Would you like to make a PR @GuillemGSubies ?
I can give it a try
go for it!
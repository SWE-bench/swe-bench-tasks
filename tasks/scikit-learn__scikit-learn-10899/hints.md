I'd be happy to see a setter for idf_.

> I'd be happy to see a setter for idf_.

But that's not what the TfidfTransformer uses internally. Shouldn't the
user be setting the _idf_diag matrix rather? I agree that setting a
private attribute is ugly, so the question is: shouldn't we make it
public?

What's wrong with providing a setter function that transforms to _idf_diag
appropriately?

> > I'd be happy to see a setter for idf_.
> 
> But that's not what the TfidfTransformer uses internally. Shouldn't the
> user be setting the _idf_diag matrix rather? I agree that setting a
> private attribute is ugly, so the question is: shouldn't we make it
> public?

As the setter for _idf_diag is defined, this does give me a workaround for my problem. This leads me to two new questions.
- Would you be interested by a snippet/ipynotebook as an example on how to store the correct attributes for CountVectorizer/TfidfTransformer to be restored ?
- I am currently unsure whether i would be able to provide a correct setter for idf_, should i keep the issue open for more skilled developpers to see ?

Thank you for the quick response

+1 on what @jnothman said

Hey, I'd be interested in working on this one.

sure go ahead @manu-chroma :)

Sorry for not getting back earlier. 
In the following code example given by the @Sbelletier :

``` python
#let us say that CountV is the previously built countVectorizer that we want to recreate identically
from sklearn.feature_extraction.text import CountVectorizer 

doc = ['some fake text that is fake to test the vectorizer']

c = CountVectorizer
c.set_params(**CountV.get_params())
c.set_params(**{'vocabulary':CountV.vocabulary_})
```

Can someone elaborate on how the `set_params funtion` works for both the lines and what are they actually taking as params. I had a look at the docs but still don't get it. Thanks.  

hi @manu-chroma 
so the `get_params()` function returns a dictionary with the parameters of the previously fit CountVectorizer `CountV` (the `**` is kwargs syntax and unpacks a dictionary to function arguments). `set_params()` does the opposite; given a dictionary, set the values of the parameters of the current object to the values in the dictionary. Here's an ipython example of the code above

```
In [1]: from sklearn.feature_extraction.text import CountVectorizer
   ...:
   ...: doc = ['some fake text that is fake to test the vectorizer']
   ...:

In [2]: CountV = CountVectorizer(analyzer="char")

In [3]: CountV.fit(doc)
Out[3]:
CountVectorizer(analyzer='char', binary=False, decode_error=u'strict',
        dtype=<type 'numpy.int64'>, encoding=u'utf-8', input=u'content',
        lowercase=True, max_df=1.0, max_features=None, min_df=1,
        ngram_range=(1, 1), preprocessor=None, stop_words=None,
        strip_accents=None, token_pattern=u'(?u)\\b\\w\\w+\\b',
        tokenizer=None, vocabulary=None)

In [4]: CountV.get_params()
Out[4]:
{'analyzer': 'char',
 'binary': False,
 'decode_error': u'strict',
 'dtype': numpy.int64,
 'encoding': u'utf-8',
 'input': u'content',
 'lowercase': True,
 'max_df': 1.0,
 'max_features': None,
 'min_df': 1,
 'ngram_range': (1, 1),
 'preprocessor': None,
 'stop_words': None,
 'strip_accents': None,
 'token_pattern': u'(?u)\\b\\w\\w+\\b',
 'tokenizer': None,
 'vocabulary': None}

In [5]: c = CountVectorizer()

In [6]: c.get_params()
Out[6]:
{'analyzer': u'word', #note that the analyzer is "word"
 'binary': False,
 'decode_error': u'strict',
 'dtype': numpy.int64,
 'encoding': u'utf-8',
 'input': u'content',
 'lowercase': True,
 'max_df': 1.0,
 'max_features': None,
 'min_df': 1,
 'ngram_range': (1, 1),
 'preprocessor': None,
 'stop_words': None,
 'strip_accents': None,
 'token_pattern': u'(?u)\\b\\w\\w+\\b',
 'tokenizer': None,
 'vocabulary': None} #note that vocabulary is none

In [7]: c.set_params(**CountV.get_params())
Out[7]:
CountVectorizer(analyzer='char', binary=False, decode_error=u'strict',
        dtype=<type 'numpy.int64'>, encoding=u'utf-8', input=u'content',
        lowercase=True, max_df=1.0, max_features=None, min_df=1,
        ngram_range=(1, 1), preprocessor=None, stop_words=None,
        strip_accents=None, token_pattern=u'(?u)\\b\\w\\w+\\b',
        tokenizer=None, vocabulary=None) #note that vocabulary is none

In [8]: c.set_params(**{'vocabulary':CountV.vocabulary_})
Out[8]:
CountVectorizer(analyzer='char', binary=False, decode_error=u'strict',
        dtype=<type 'numpy.int64'>, encoding=u'utf-8', input=u'content',
        lowercase=True, max_df=1.0, max_features=None, min_df=1,
        ngram_range=(1, 1), preprocessor=None, stop_words=None,
        strip_accents=None, token_pattern=u'(?u)\\b\\w\\w+\\b',
        tokenizer=None,
        vocabulary={u'a': 1, u' ': 0, u'c': 2, u'e': 3, u'f': 4, u'i': 6, u'h': 5, u'k': 7, u'm': 8, u'o': 9, u's': 11, u'r': 10, u't': 12, u'v': 13, u'x': 14, u'z': 15})
```

Notice how in `CountV` the value of `analyzer` is `char` and in `c` the value of `analyzer` is `word`. `c.set_params(**CountV.get_params())` sets the parameters of `c` to those of `CountV`, and that the `analyzer` is accordingly changed to `char`.

Doing the same thing to `vocabulary`, you can see that running `c.set_params(**{'vocabulary':CountV.vocabulary_})` sets `c` to have the vocabulary of the previously fit `CountVectorizer` (`CountV`), despite it not being fit before (thus having a `vocabulary` value of `None` previously).

hey @nelson-liu, thanks so much for explaining. I didn't know about `kwargs syntax`before.

So essentially, a new setter function would be added to class `TfidfVectorizer` to alter the parameter `idf_` ? Want to make things clearer for myself before I code. Thanks.

I looked through this, and it isn't really possible to add a setter for idf_ that updates _idf_diag @manu-chroma @nelson-liu @amueller @jnothman. The reason being when we set _idf_diag we use n_features which comes from X in the fit function text.py:1018. So we would have to keep track of n_features, add it to the setter, or we could move over to setting _idf_diag directly as @GaelVaroquaux suggested. I would suggest we directly set _idf_diag since we aren't really keeping the state necessary for idf_ but that's just my humble opinion. *Note when we get idf_ we are actually deriving it from _idf_diag text.py:1069
Below is a test that I used to start out the code.

``` python
def test_copy_idf__tf():
    counts = [[3, 0, 1],
              [2, 0, 0],
              [3, 0, 0],
              [4, 0, 0],
              [3, 2, 0],
              [3, 0, 2]]
    t1 = TfidfTransformer()
    t2 = TfidfTransformer()
    t1.fit_transform(counts)
    t2.set_params(**t1.get_params())
    #t2.set_params(**{'idf':t1.idf_})
    t2.idf_ = t1.idf_
```

Surely the number of features is already present in the value of _idf_diag?
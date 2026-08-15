Thanks for the report, I think changing 

```py
self.n_trees_per_iteration_ = 1 if n_classes <= 2 else n_classes
```
to
```
self.n_trees_per_iteration_ = n_classes
```

would make categorical-crossentropy behave like the log loss.

But I think we want to error in this case: categorical-crossentropy will be twice as slow. This is a bug right now

Submit a PR Adrin?
I'm happy to submit a PR, but do we want to have two trees for binary classification and categorical crossentropy and one tree for binary crossentropy? And then raise a warning if categorical crossentropy is used for binary classification?
> do we want to have two trees for binary classification and categorical crossentropy and one tree for binary crossentropy? 

I'd say no, we should just error. But no strong opinion. I don't see the point of allowing categorical crossentropy in binary classification when the log loss is equivalent and twice as fast. Especially considering the loss='auto' which is the default.
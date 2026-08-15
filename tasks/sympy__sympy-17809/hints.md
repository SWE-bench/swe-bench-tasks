
I think to make it work in general `cosh(x).is_positive` should be True. It's strange that simplify works. It must be attempting some rewrites that cause it to reduce (like `rewrite(exp)`). 

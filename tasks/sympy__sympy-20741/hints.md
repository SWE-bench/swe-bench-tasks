The problem here is-

` - (A+B)` and similar expressions with `-` sign outside bracket isn't being evaluated.
I think its `MatMul` which isn't evaluating `-(A+B)` . I'll try to dig in deeper.
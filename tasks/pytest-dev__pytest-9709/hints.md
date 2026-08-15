-1 on that - unlike ordered sequences, sets would have to "magically" match the right approximations with the right values

however we should warn or error on unordered sequences
Thanks for reacting. Yes, that is why I suggested that sets should be forbidden in approx. (They are not. Instead, they are explicitly mentioned in the code.)  It is not enough to check for `__iter__()`. One has to check for the presence of `__getitem__()`.

(I don't understand your -1, though. Sorry for trying to help ...)
PS: You are confusing ABCs, again. Sequences are **always** ordered, because they have a `__getitem__()` method. That is my whole point.
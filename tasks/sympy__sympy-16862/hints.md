Ping @aktech 

> As calling args[0] on an empty set raises an IndexError.

A try catch should be used there.

> Also, why are we type-casting the set to a list ?

It doesn't looks like we should, we are typecasting the first argument of `FiniteSet` returned by `linsolve` which is a `tuple`, & it's unneccesary to typecast a tuple to a list in this case.

> A try catch should be used there.

Wouldn't an `if` condition checking the size of returned tuple be better suited here ?

> it's unneccesary to typecast a tuple to a list in this case.

Should we remove it and work on the returned tuple itself ?

> Wouldn't an if condition checking the size of returned tuple be better suited here ?

We wouldn't have a tuple when `EmptySet()` is returned.

> Should we remove it and work on the returned tuple itself ?

Yes.

> We wouldn't have a tuple when EmptySet() is returned.

Yeah. Actually, I meant an `if` condition to check the size of the returned set from `linsolve`.
If its an `EmptySet`, we  can directly return `False`.

Did #10645 address this issue?

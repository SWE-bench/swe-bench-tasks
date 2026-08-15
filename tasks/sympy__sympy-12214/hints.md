It appears that _add_splines was planned for the case when all the knots are distinct. Otherwise there are intervals of length zero, and those are not included in Piecewise. Then _add_splines will be confused.

Also having problems with this. Is there no way of generating B-splines with repeated knots and order > 1?
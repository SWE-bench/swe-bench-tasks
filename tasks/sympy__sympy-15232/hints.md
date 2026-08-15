Just shortsightedness - I didn't know that you can declare an object as noncommutative. In that case I guess you would add another test like `if all(...) and a.?.is_commutative is ?`. You would have to fill in the ? with whatever is needed to test that the object itself is non-commutative.

see also #5856 and #6225

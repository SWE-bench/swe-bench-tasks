I think this was used originally to be able to assert that  a list of checker is equal to another one in tests. If it's not covered it means we do not do that anymore.
It's used in Sphinx and maybe downstream libraries see #6047 .
Shall we add a no coverage param then?
It's pretty easy to add a unit test for this so will make a quick PR
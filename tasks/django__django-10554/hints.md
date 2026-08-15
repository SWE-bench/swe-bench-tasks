Looks like a bug caused by a .query attribute change without performing a prior copy() of the query/queryset.
Attaching a regression test that fails on master (tested at f3d3338e06d571a529bb2046428eeac8e56bcbf6).
​PR
Tests aren't passing.
Needs more tests, at the least. But discussion on PR suggests we've not hit the right strategy yet.
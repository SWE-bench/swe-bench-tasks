I created a pull request: ​https://github.com/django/django/pull/1093
I verified the problem exists. The patch fixes the problem, and has tests.
Since it might not be clear, I'd like to point that the reason we can't simply decorate mark_safe with allow_lazy is that mark_safe can return either bytes or text. The allow_lazy decorator cannot handle this case (there are specific checks in the code for it). [1] [1] ​https://github.com/django/django/blob/master/django/utils/functional.py#L106
In 2ee447fb5f8974b432d3dd421af9a242215aea44: Fixed #20296 -- Allowed SafeData and EscapeData to be lazy
In a878bf9b093bf15d751b070d132fec52a7523a47: Revert "Fixed #20296 -- Allowed SafeData and EscapeData to be lazy" This reverts commit 2ee447fb5f8974b432d3dd421af9a242215aea44. That commit introduced a regression (#21882) and didn't really do what it was supposed to: while it did delay the evaluation of lazy objects passed to mark_safe(), they weren't actually marked as such so they could end up being escaped twice. Refs #21882.
A better fix for the issue is here: ​https://github.com/django/django/pull/2234
The current PR does not merge cleanly.
I closed the PR (it is still there for anyone who'd like to see how it looked like). If I have some time, I'll try to see if the approach still works and I'll reopen it. Thanks for the ping.
In the steps to reproduce, should mark_safe() be inside ugettext_lazy() as in #27803 instead of the other way around? If so, maybe this is a wontfix, assuming the documentation is clear about proper usage.
This should be an easy fix now I believe. mark_safe no longer operates on both bytes and text, so wrapping it with keep_lazy (the new allow_lazy) should solve the issue.
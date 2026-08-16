In my opinion, this issue is caused by encoding to shift_jis doesn't raise UnicodeError when characters which are out of JIS X 0201 are given.  So I guess that this is fixed by encoding to jis correctly.

If you don't mind, please assign this issue to me. I will make a PR  for this issue.
Thanks for the report - of course you can make a PR for this, please go ahead! 
Dear all.
I'm trying to solve this issue. And I want some advice about the scope of this issue and the way of implementation.
May I discuss them in this issue thread? Or should I create a PR and add W.I.P to its title?
Whatever suits you better - if you want to discuss concrete code, it may be easier to add a PR to be able to comment on specific lines, but that's completely up to you!
@mrbean-bremen 

Thank for your quick reply. I got it. First, I will write some concrete codes. And then I'll make a PR and want to discuss there. 
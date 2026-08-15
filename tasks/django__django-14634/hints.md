The patch for this contribution
Your patch sets the message before the object is deleted. What if deleting the object fails? Otherwise, this addition makes sense.
Here is a pull request that approaches the problem from a different angle: ​https://github.com/django/django/pull/2585 Instead of adding a new mixin, the DeleteView is refactored to allow it to work with the existing SuccessMessageMixin. Thanks to @charettes for the approach and much of the code.
The approach seems sensible to me and the patch looks quite good. I'm going to mark this as ready for checkin so that we can get another set of eyes on this in case I've missed something. Thanks!
I see one small issue: the comment on line ​https://github.com/django/django/pull/2585/files#diff-2b2c9cb35ddf34bc38c90e322dcc39e8L201 still seems valid to me: the documented behaviour has changed, but I don't see a versionchanged annotation, which should be there in a case like this.
Bug #21926 was a duplicate of this one.
My main concern with the patch that I have provided is that there are changes related to using the DELETE method for deletions, but it doesn't work entirely as expected. For example, if an application uses a form to verify that a field should be deleted. If the view were to have code that checks that a confirmation box is checked or something similar, and they used the DELETE HTTP method, then the view would not work correctly, as data is not passed through with the request in the case of DELETE. So the documentation change where I changed it to read that you can use DELETE, and a few other changes in the code may not be valid. There was a comment in the pull request that got buried I think: "As I was updating the tests, I found that data cannot currently be sent with the DELETE method. When doing further research, I wasn't sure whether this should be allowed or not. The test client accepts a data parameter for DELETE, but the HTTP spec suggests that you shouldn't expect data, like you can for a POST: ​http://www.w3.org/Protocols/rfc2616/rfc2616-sec9.html#sec9.7 If we want to I can figure out how to actually get data through the chain. Otherwise I can update the documentation to reflect the changes instead." I wasn't sure how to proceed: to remove the parts related to supporting the DELETE method, or to try to figure out how to get the data through the DELETE chain.
I've updated the patch with feedback from review.
new pull request send with moving the conflicting tests.
Thanks for the new PR. For the record, this is ​https://github.com/django/django/pull/4256 I left a comment on GitHub regarding the code style issues.
Is there any status update on this?
We are waiting for someone to update the pull request as described in comment 13.
I will new PR
new PR ​https://github.com/django/django/pull/5992
re started working on it. will send the updated pr on master tomorrow
Just wanted to remind this is an important feature/fix. Thanks in advance
Thanks to all for their work on this. I did some minor changes to the original pull request that become inactive, and submitted a new pull request here ​https://github.com/django/django/pull/13362
Comments on PR. I think comment:9 is important: not clear adding the delete handling makes too much sense.
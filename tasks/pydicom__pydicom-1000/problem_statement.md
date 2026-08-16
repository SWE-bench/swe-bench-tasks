Heuristic for Explicit VR acting in sequence datasets
**Describe the bug**
There is a check to confirm implicit VR by looking for two ascii characters and switching to explicit with a warning (#823).  It was thought this was safe because length in first data elements would not be that large.  However, in sequence item datasets this may not be true.

Noted in google group conversation at https://groups.google.com/forum/#!topic/pydicom/VUmvUYmQxc0 (note that the title of that thread is not correct. that was not the problem).

Test demonstrating it and fix already done - PR to follow shortly.


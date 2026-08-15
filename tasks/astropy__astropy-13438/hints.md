Welcome to Astropy 👋 and thank you for your first issue!

A project member will respond to you as soon as possible; in the meantime, please double-check the [guidelines for submitting issues](https://github.com/astropy/astropy/blob/main/CONTRIBUTING.md#reporting-issues) and make sure you've provided the requested details.

GitHub issues in the Astropy repository are used to track bug reports and feature requests; If your issue poses a question about how to use Astropy, please instead raise your question in the [Astropy Discourse user forum](https://community.openastronomy.org/c/astropy/8) and close this issue.

If you feel that this issue has not been responded to in a timely manner, please leave a comment mentioning our software support engineer @embray, or send a message directly to the [development mailing list](http://groups.google.com/group/astropy-dev).  If the issue is urgent or sensitive in nature (e.g., a security vulnerability) please send an e-mail directly to the private e-mail feedback@astropy.org.
Besides the jquery files  in [astropy/extern/jquery/data/js/](https://github.com/astropy/astropy/tree/main/astropy/extern/jquery/data/js), the jquery version number appears in [astropy/table/jsviewer.py](https://github.com/astropy/astropy/blob/main/astropy/table/jsviewer.py) twice, and in [table/tests/test_jsviewer.py](https://github.com/astropy/astropy/blob/main/astropy/table/tests/test_jsviewer.py) four times. This might be a good time to introduce a constant for the jquery version, and use that ~across the codebase. Or at least~ across the tests.

@skukhtichev Maybe we could speed up the fix by creating a PR?
As Python does not have built-in support for defining constants, I think it's better to keep the hard-coded strings in [astropy/table/jsviewer.py](https://github.com/astropy/astropy/blob/main/astropy/table/jsviewer.py). Don't want to introduce another security problem by allowing attackers to downgrade the jquery version at runtime. Still, a variable for the tests would simplify future updates.
> Maybe we could speed up the fix by creating a PR?

That would definitely help! 😸 

We discussed this in Astropy Slack (https://www.astropy.org/help.html) and had a few ideas, the latest being download the updated files from https://cdn.datatables.net/ but no one has the time to actually do anything yet.

We usually do not modify the bundled code (unless there is no choice) but rather just copy them over. This is because your changes will get lost in the next upgrade unless we have a patch file on hand with instructions (though that can easily break too if upstream has changed too much).
I'll see what I can do about a PR tomorrow :-)
I'd get the jquery update from https://releases.jquery.com/jquery/, latest version is 3.6.0.
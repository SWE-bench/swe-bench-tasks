Welcome to Astropy 👋 and thank you for your first issue!

A project member will respond to you as soon as possible; in the meantime, please double-check the [guidelines for submitting issues](https://github.com/astropy/astropy/blob/main/CONTRIBUTING.md#reporting-issues) and make sure you've provided the requested details.

GitHub issues in the Astropy repository are used to track bug reports and feature requests; If your issue poses a question about how to use Astropy, please instead raise your question in the [Astropy Discourse user forum](https://community.openastronomy.org/c/astropy/8) and close this issue.

If you feel that this issue has not been responded to in a timely manner, please send a message directly to the [development mailing list](http://groups.google.com/group/astropy-dev).  If the issue is urgent or sensitive in nature (e.g., a security vulnerability) please send an e-mail directly to the private e-mail feedback@astropy.org.
Huh, so we do have this format... https://docs.astropy.org/en/stable/io/ascii/index.html

@taldcroft , you know anything about this?
This is the format I'm using, which has the issue: https://docs.astropy.org/en/stable/api/astropy.io.ascii.QDP.html

The issue is that the regex that searches for QDP commands is not case insensitive. 

This attached patch fixes the issue, but I'm sure there's a better way of doing it.

[qdp.patch](https://github.com/astropy/astropy/files/10667923/qdp.patch)

@jak574 - the fix is probably as simple as that. Would you like to put in a bugfix PR?
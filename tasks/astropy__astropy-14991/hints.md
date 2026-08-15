Welcome to Astropy 👋 and thank you for your first issue!

A project member will respond to you as soon as possible; in the meantime, please double-check the [guidelines for submitting issues](https://github.com/astropy/astropy/blob/main/CONTRIBUTING.md#reporting-issues) and make sure you've provided the requested details.

GitHub issues in the Astropy repository are used to track bug reports and feature requests; If your issue poses a question about how to use Astropy, please instead raise your question in the [Astropy Discourse user forum](https://community.openastronomy.org/c/astropy/8) and close this issue.

If you feel that this issue has not been responded to in a timely manner, please send a message directly to the [development mailing list](http://groups.google.com/group/astropy-dev).  If the issue is urgent or sensitive in nature (e.g., a security vulnerability) please send an e-mail directly to the private e-mail feedback@astropy.org.
@nstarman ?
@RyanCamo, thanks for opening the issue! Indeed, that would be an impactful error. Can you please share your Wolfram notebook?

Yeah no worries. https://www.wolframcloud.com/obj/05284bb5-e50d-4499-ab2c-709e23e49007
I get the same thing, following the steps in the FLRW base class.

<img width="438" alt="Screenshot 2023-06-23 at 22 49 12" src="https://github.com/astropy/astropy/assets/8949649/c1b3cdc3-051a-47d9-8a2a-7fd71cdafb10">

Let me track down when this class was first made. It's hard to believe it could be wrong for so long without being noticed... 
Git says this was introduced in #322. @aconley, this was your PR. I know this was 11 years ago, but perhaps you could take a look.
Ryan is correct, it should be a +3.

This probably went detected for so long because nobody would ever use the w0/wz formulation, it's horribly unstable.  w0/wa is almost always a better idea -- w0/wz was just included for completeness.
If you want a citation for the +3, it's on the first page of Linder et al. 2003.
@jranalli thanks for finding and reporting this. Can I ask how you contacted PVLIB MATLAB? Because I maintain that repository and I didn't see the email, so we need to fix something on our end with communications.
@cwhanse Now that I look again, I think I used the wrong form. It was just a general Questions and Comments link for the PV Performance Modeling Collaborative at the bottom of the page. I didn't see any contact point for the PV_LIB MATLAB library and I also didn't know about the github repo for it, but now I do! 

I do have a fix for the MATLAB code as well, but I don't see that part of the library on github. If you'd like me to open an issue on that repository as well, I'd be happy to do so, but if there's some other pathway or contact point since that's kind of listed as a separate package of the code, please let me know.

Either way, do you think it's appropriate to fix this, or does there need to be a conversation with the original author of that MATLAB code? If everything is fine to go ahead with it here, I can just put together my fix as a pull request for review.


And did my own looking: pvl_WVM is in it's own Matlab archive, separate from PVLIB for Matlab. The WVM code is only available as a download from pvpmc.sandia.gov, whereas PVLIB for Matlab is on [github](https://github.com/sandialabs/MATLAB_PV_LIB).

I've sent the bug report to Matt Lave, the originator of the WVM algorithm and code. We'll likely welcome the bug fix but I'd like to hear Matt's view first.
OK sounds good. If he or you want to connect for more detail on the issue, you can get contact info for me at my [Faculty Page](http://personal.psu.edu/jar339/about.html).
for the record: bug is confirmed via separate communication with the WVM algorithm author.
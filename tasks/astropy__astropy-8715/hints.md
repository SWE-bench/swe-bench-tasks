Good enough for FITS, good enough for me. This would address https://github.com/astropy/astropy/pull/7928#issuecomment-434031753 .

Do you have any strong opinions about this, @tomdonaldson and @theresadower ?
👍 to having a `verify` key and 👍 to `ignore` as the default.
👍to this, and 4.0 is a good time to do it, @astrofrog.  But perhaps there should be a configuration item or other global-ish state that can be turned on?  My thinking is that this might be good as a tool to test what's valid and what is not in particular workflows.
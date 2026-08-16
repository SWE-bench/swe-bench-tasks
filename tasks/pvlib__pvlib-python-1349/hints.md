Thanks @cweickhmann!  I want to take a closer look at the technical report to be sure, but on a first glance I think the problem here is the same one solved by the line marked with `# GH 526` in `irradiance.haydavies`:

https://github.com/pvlib/pvlib-python/blob/aba071f707f9025882e57f3e55cc9e3e90e869b2/pvlib/irradiance.py#L811-L816

Note that, even though `spectrum.spectrl2` uses `irradiance.haydavies` under the hood, the above branch is not hit because `spectrl2` passes in a pre-calculated `projection_ratio`.  So I think clipping the projection to be non-negative before passing it to `haydavies` would solve the problem.  The `# GH 432` line might be desirable as well, though I don't think it's relevant for this issue.  

Does anyone have qualms about us deviating from the reference by implementing that fix and making a note about it in the docstring?  `aoi > 90` is hardly an uncommon occurrence, even for arrays that aren't high-latitude and facing north. 
> deviating from the reference by implementing that fix and making a note about it 

I support that.
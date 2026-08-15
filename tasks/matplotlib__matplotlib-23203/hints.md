I think maybe this is the problem line:
https://github.com/matplotlib/matplotlib/blob/08732854e815ccbc99f382d99609255929979515/lib/matplotlib/colorbar.py#L1620

and it should be handled the same as in `make_axes`
https://github.com/matplotlib/matplotlib/blob/08732854e815ccbc99f382d99609255929979515/lib/matplotlib/colorbar.py#L1459

https://github.com/matplotlib/matplotlib/blob/08732854e815ccbc99f382d99609255929979515/lib/matplotlib/colorbar.py#L1507-L1508
This was recently changed in https://github.com/matplotlib/matplotlib/pull/22776 to fix a problem introduced in https://github.com/matplotlib/matplotlib/pull/20129

Maybe @QuLogic and @anntzer knows more about the details.
Actually the code prior to #20129 also didn't have the `if loc_settings["panchor"] is not False:` check, so I don't think my changes really matter here?  Without having carefully checked, the proposed fix makes sense, though.
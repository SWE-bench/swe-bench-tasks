I don't really have a good feel for whether what you are asking for is possible or not, but have you tried the `notebook` backend, or the `widgets` backend?  They seem suited to what you want to do.  
I guess I have a few issues with `notebook` and `widgets`:
 - You can't easily switch between `inline` and `notebook`/`widgets`
 - Plots made with `notebook`/`widgets` don't have a good static representation in an exported copy of a notebook (like HTML) which I use to share work with non-devs
 - Plots made with `widgets` backend don't show up when a notebook is opened but hasn't yet been run (showing "Error displaying widget: model not found" instead of showing the plot as it was last generated) - this also affects visibility of plots in notebooks rendered on GitHub, GitLab, nbviewer, etc
 - Embedded plots can never use the whole screen or any of my extra monitors - a big part of why my team wants the ability to "pop-out" a plot into it's own window is so that it can be expanded to fill a monitor - possibly a different monitor than the one jupyterlab is in.
Just a note that `notebook` plots certainly have a static html, but agree that `widget` plots don't.

Fair enough about "pop-out" plots.  Hopefully someone here can speak to how those work or if there is a workflow that can suit your needs.

See also https://github.com/matplotlib/matplotlib/pull/14471.

I *think* this should be doable (if the event loops are not compatible we error out anyways, but otherwise I don't see why we can't have e.g. qt5agg and qt5cairo windows coexisting)?  Does simply removing the call to `close("all")` in the implementation of `pyplot.switch_backend` work for you?

If that works there's a reasonable way forward with the behavior change (of ultimately not calling `close("all")`: during the transition period, warn if any windows are getting closed and tell the user to call `close("all")` explicitly.
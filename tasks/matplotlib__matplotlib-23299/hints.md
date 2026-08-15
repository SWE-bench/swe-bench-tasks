My knee-jerk guess is that  :  

 - the `rcParams['backend']` in the auto-sentinel
 - that is stashed by rc_context
 - if you do the first thing to force the backend to be resolved in the context manager it get changes
 - the context manager sets it back to the sentinel an the way out
 - `get_backend()` re-resolves the backend which because it changes the backend it closes all of the figures


This is probably been a long standing latent bug, but was brought to the front when we made the backend resolution lazier.
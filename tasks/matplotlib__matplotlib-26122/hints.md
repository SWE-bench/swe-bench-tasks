Hi,
If no one is working on this issue than i would like to give it a shot. Can you please guide how can i address this issue?

Thanks.
I honestly do not think that this is a "good first issue", especially due to the part about `transData` being a branch of some other transform. So in order not to confuse newcomers too much, I think it makes sense to remove that first-issue-label.
Where is the transform kwarg?

https://matplotlib.org/3.1.3/api/_as_gen/matplotlib.pyplot.imshow.html
It falls though via `**kwargs` to eventually hit https://matplotlib.org/3.1.3/api/_as_gen/matplotlib.artist.Artist.set_transform.html#matplotlib.artist.Artist.set_transform via at call to https://github.com/matplotlib/matplotlib/blob/cfd5463edaafd1a2300f9b122ccbbdc983d8b8eb/lib/matplotlib/artist.py#L968-L993 
This issue has been marked "inactive" because it has been 365 days since the last comment. If this issue is still present in recent Matplotlib releases, or the feature request is still wanted, please leave a comment and this label will be removed. If there are no updates in another 30 days, this issue will be automatically closed, but you are free to re-open or create a new issue if needed. We value issue reports, and this procedure is meant to help us resurface and prioritize issues that have not been addressed yet, not make them disappear.  Thanks for your help!
I think that wouldn't be too hard to add but @jakevdp knows better.

Thats good news. 
Well I would use it for astronomy project, so @jakevdp  help/advice would be welcome. 
Hope to be able to work on it after paper deadlines, but can't promise anything. 

It's actually not trivial, because of the fast tree-based KDE that sklearn uses. Currently, nodes are ranked by distance and the local estimate is updated until it can be shown that the desired tolerance has been reached. With non-uniform weights, the ranking procedure would have to be based on a combination of minimum distance and maximum weight in each node, which would require a slightly different KD-tree/Ball tree traversal algorithm, along with an updated node data structure to store those weights.

It would be relatively easy to add a slower brute-force version of KDE which supports weighted points, however.

Hum, for some reason I thought the trees did support weights. I guess I was confused by the weighting in KNN which is much easier to implement.

Quick question – I've heard a number of requests for this feature. Though it would be difficult to implement for the tree-based KDE, it would be relatively straightforward to add an `algorithm='brute'` option to `KernelDensity` which could support a `weights` or similar attribute for the class.

Do you think that would be a worthwhile contribution?

I think it would. In practice it means it would it would only be practical for small-ish data sets of course, but I don't see that as not a good reason to implement it. 
Furthermore, if proven popular, it might lead to someone developing a fast version.  
just my 2 cents

Just a comment - for low dimensional data sets statsmodels already has a weighted KDE.

It would also be extremely convenient for me if there was a version of the algorithm that accepted weights. I think it's a very important feature and surprisingly almost none of the python libraries have it. Statsmodels does have it, but only for univariate KDE; for multivariate KDE the feature is also missing.
2 years have passed since this issue was opened and it hasn't been solved yet
Do you want to contribute it? Go ahead!
Hi, I'm interested in this too. What about this?

https://gist.github.com/afrendeiro/9ab8a1ea379030d10f17

I can ask and try and integrate this into sklearn if you think it's fine.
I think that wouldn't be too hard to add but @jakevdp knows better.

Thats good news. 
Well I would use it for astronomy project, so @jakevdp  help/advice would be welcome. 
Hope to be able to work on it after paper deadlines, but can't promise anything. 

It's actually not trivial, because of the fast tree-based KDE that sklearn uses. Currently, nodes are ranked by distance and the local estimate is updated until it can be shown that the desired tolerance has been reached. With non-uniform weights, the ranking procedure would have to be based on a combination of minimum distance and maximum weight in each node, which would require a slightly different KD-tree/Ball tree traversal algorithm, along with an updated node data structure to store those weights.

It would be relatively easy to add a slower brute-force version of KDE which supports weighted points, however.

Hum, for some reason I thought the trees did support weights. I guess I was confused by the weighting in KNN which is much easier to implement.

Quick question – I've heard a number of requests for this feature. Though it would be difficult to implement for the tree-based KDE, it would be relatively straightforward to add an `algorithm='brute'` option to `KernelDensity` which could support a `weights` or similar attribute for the class.

Do you think that would be a worthwhile contribution?

I think it would. In practice it means it would it would only be practical for small-ish data sets of course, but I don't see that as not a good reason to implement it. 
Furthermore, if proven popular, it might lead to someone developing a fast version.  
just my 2 cents

Just a comment - for low dimensional data sets statsmodels already has a weighted KDE.

It would also be extremely convenient for me if there was a version of the algorithm that accepted weights. I think it's a very important feature and surprisingly almost none of the python libraries have it. Statsmodels does have it, but only for univariate KDE; for multivariate KDE the feature is also missing.
2 years have passed since this issue was opened and it hasn't been solved yet
Do you want to contribute it? Go ahead!
Hi, I'm interested in this too. What about this?

https://gist.github.com/afrendeiro/9ab8a1ea379030d10f17

I can ask and try and integrate this into sklearn if you think it's fine.
Thank you for the report and the detailed analysis.

A pull request to improve the memory usage in `IsolationForest` would be very much appreciated!

Also if possible please use code formatting in Github comments -- it really helps readability (I edited your comment above) , and it possible to use some other format than .docx for sharing documents (as it's difficult to open it on Linux). Thanks!
Thanks for a very prompt response.
I'm new to GitHub, not really sure of the process here. :)

Wants to first confirm that it's a valid issue & possible to resolve memory consumption as I have mentioned.
Current memory consumption is quite high(~5GB) for 1000 estimators.

The attached document has images too & so .docx. Any preference as what format to use for future sharing. 


If I understand correctly, the issue is that in `IsolationForest.decision_function` one allocates two arrays `n_samples_leaf` and `depths` or shape `(n_samples, n_estimators)`. When n_samples is quite large (I imagine it's ~200k in your case?) for large `n_estimators` this can indeed take a lot of memory. Then there are even more such allocations in `_average_path_length`.

I agree this can be probably optimized as you propose. The other alternative could be just to chunk X row wise then concatenate the results (see related discussion in https://github.com/scikit-learn/scikit-learn/pull/10280).

If you make a Pull Request with the proposed changes (see [Contributing docs](http://scikit-learn.org/stable/developers/contributing.html#how-to-contribute)), even if it's work in progress, it will be easier to discuss other possible solutions there while looking at the code diff.

**Edit:** PDF might be simpler to open, or just posting the results in a comment on Github if it's not too much content. You can also hide some content with the [details tag](https://gist.github.com/citrusui/07978f14b11adada364ff901e27c7f61).
Hello, yes that exactly the issue with isolation forest. The dataset is indeed large 257K samples with 35 numerical features. However, that even needs to be more than that as per my needs and so looking for memory efficiency too in addition to time.

I have gone through the links and they are quite useful to my specific usecases(I was even facing memory issues with sillloutte score and brute  algo).
I'm also exploring dask package that works on chunks using dask arrays/dataframes and if can alternatively be used in places where sklearn is consuming memory.

Will be first working on handling the data with chunks and probably in coming weeks will be making the PR for isoforest modification as have to go through the research paper on iso forest algo too. Also looking for other packages/languages than sklearn as how they are doing isoforest.
Here's the bagging implementation seems quite different, i.e. I think the tree is getting build for each sample instead of simply making n_estimators tree and then apply on each sample- In any case I have to understand few other things before starting work/discussion on this in detail.


working on this for the sprint. So to avoid arrays of shape `(n_samples, n_estimators)` in memory, we can either:
1) updating the average when going through the estimators which will decrease the in-memory shape down to `(n_samples,)`
2) chunk the samples row wise

We can also do both options I guess.
I'm not sure if 1) can be done easily though, looking into it.
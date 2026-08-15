(Also, hi Stephen!)
Could you explain why you want to handle this case?

I would rather raise an error if the diag is not close to 0.

(Also, upgrading to 0.20 may give you much better performance for silhoette calculations on large samples)
Hi Joel!

I'd like to handle this case because it isn't completely clear from the documentation. The equations used to explain the behaviour of the function do not require the use of the diagonal entries, yet they are still involved in the calculation. Likely this is for ease of implementation and speed.

Thanks for the tip about 0.2. I have updated now (and updated the original issue text).
But why, when silhouette deals in distances, would you have the distance from a point to itself not equal to 0? Or is it just that you are filling the matrix in a way that leaves these cells arbitrary, and you had expected the results to be invariant to their value?
The latter. The values in the diagonal cells are arbitrary and I expected the result to be invariant to their value.

I understand that the distance matrices produced by pairwise_distances (which I think recently was changed to paired_distances) will always have these values set to 0. However my distance matrix did not conform to this format.
[No, paired and pairwise do different things and have for at least 5 years. Pairwise calculates distances over a cartesian product of two sets of samples (defaulting to a set and itself). Paired deals with specified pairings.]

So let's do a little validation and raise an error if the diagonal is non-zero.
Feel free to submit a PR
> [No, paired and pairwise do different things and have for at least 5 years. Pairwise calculates distances over a cartesian product of two sets of samples (defaulting to a set and itself). Paired deals with specified pairings.]

Yes you're right. Seems like my browser was pushing me to metrics.pairwise.pairwise_distances instead of metrics.pairwise_distances, leading me to believe that it had been removed.
If this is still in need of fixing, I'd like to take this on.
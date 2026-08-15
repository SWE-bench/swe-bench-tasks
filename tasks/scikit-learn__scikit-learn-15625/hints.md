I'm okay with giving options. I think calling it precision/recall/accuracy
is a bit misleading since they don't pertain off the diagonal of the
matrix. true vs pred might be better names. It's still not entirely clear
to me that providing this facility is of great benefit to users.

With your proposal, you also need to implement tests to ensure that the function will work properly.
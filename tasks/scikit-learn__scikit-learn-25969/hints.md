@rth @thomasjpfan @ogrisel Here comes the PR that should refactor the code of the `_get_response`. For the moment I did not find and replace where is used to only focus on the tools. Indeed, there is nothing different from the original PR but I am thinking that it might be easier to review first this part, and then I could open a subsequent PR to find and replace the places where to use these tools.

WDYT?
If you need to be convinced regarding where these two functions will be used, you can have a quick look at the older PR: https://github.com/scikit-learn/scikit-learn/pull/18589
I added 2 examples of where the method will be used for the display. Be aware that the main point of moving `_get_response` outside of the `_plot` module is that I will be able to use it in the `scorer`. The second advantage is that we will make sure that we have a proper handling of the `pos_label`.
> What do you think of breaking this PR into two smaller ones?

I will try to do that in a new PR. I will keep this one as is to facilitate the rebasing later.
Let's move that to 1.2
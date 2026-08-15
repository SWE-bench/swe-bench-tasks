> Actual Results
>
> The test results min/max values are much larger than the training results, because fewer examples were used.

@andrewww Thanks for opening this issue. I can confirm your results (they are also true for the `MiniBatchSparsePCA`), and that in unit tests `sklearn/decomposition/tests/test_sparse_pca.py` the transform value does not seem to be validated as far as I could see. 
 
How do you propose to make sure that your solution is correct? For instance, is there a case where `SparsePCA` should produce the same results as `PCA` (e.g. by setting `alpha=0`)? Otherwise is it possible to either validate the results with [the example in the original paper](https://web.stanford.edu/~hastie/Papers/spc_jcgs.pdf) (section 5.5) or with those produced by some other implementation?  cc @vene 
@rth Honestly, I had not dug into the math to determine what the correct solution would be; I merely discovered the dependency on number of examples, knew that was wrong, and proposed a solution that at least eliminates that dependency.

I suspect the examples in the original paper is the best approach (you mention section 5.5, but I only see 5.1 through 5.3, which really are three separate examples that would make good unit tests). 

Again, I did not dig through the math, but if I assume that SPCA is what I think it is (PCA estimated with an L1 penalty altering the original loss function), then `alpha=0` should recover the PCA solution and again that yields good unit tests.

I feel like a terrible contributor, but all I can really do from where I sit is comment on bugs and provide typed ideas of solutions in comments. Artifact of my job.
> I feel like a terrible contributor, but all I can really do from where I sit is comment on bugs and provide typed ideas of solutions in comments. Artifact of my job.

Well, all your previous bug reports were accurate and provided a fix: that is very helpful. Thank you )

 Someone would just need to investigate this issue in more detail...
This seems like a bug indeed although I don't know much about SparsePCA. I quickly looked at it and the PCA does not give the same results as the SparsePCA with alpha=0 and ridge_alpha=0 (whether they should or not I am not sure). One thing I noticed is that `spca.components_` are not normalized (in contrary to `pca.components_`) and their norms seems to depend on the size of the data as well so maybe there was some logic behind the transform scaling ...

I discussed with @GaelVaroquaux and I'll try to take care of it.
The summary of our discussion : 
I have to verify that the spca and pca components are the same modulo a rotation and a normalization which is our hyporthesis. From there : change the behaviour of SparsePCA and define a deprecation path. We suggest to add a scale_components parameter to SparsePCA with default value = False which would leave things untouched. If this parameter is set to True then we compute the norm of the components during training and normalize with it this should mitigate the scaling problem. If everything works out we deprecate the default scale_components=False.
Hopefully I'll manage to do that during the sprint.
Indeed the result with no regularization will only match PCA up to rotation & scaling because they are constrained differently (our SPCA does not have orthonormal constraints). I suspect they should have equal reconstruction MSE, right?

According to this discussion I agree the current transform is indeed wrong. As far as I understand the proposed fix is about .fit, not .transform-- when you say "leave things untouched" you mean other than fixing the .transform bug? If not, with scale_components=True will transform be normalized twice?

(Disclaimer: I'm missing a lot of context and forgot everything about the code)
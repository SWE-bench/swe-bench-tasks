+1

+1

@arjoly @mblondel is anyone working on this right now?

Hi,

I'd like to help.

@arjoly @mblondel @MechCoder , may I take this one?

Only if it is ok for you @MechCoder .

You can take this one. :-)

sure :)

Ok! I'll try my best. :)

@eyaler 
In this pROC package, it is possible to choose between "specificity" (fpr) and "sensitivity" (tpr).
And both are determined by an interval, e.g. [0.8, 1.0]

Should I do the same?

@karane
thank you for taking this.
I am only familiar with the use case of looking at the pAUC over an interval of low fpr (high specificity)

@eyaler 
you're welcome

That's Ok. I think I got it. :)

@eyaler The partial AUC is indeed usually defined in the low FPR interval. This is also the way McClish described it in her seminal paper (in [McClish, 1989](http://www.ncbi.nlm.nih.gov/pubmed/2668680?dopt=Abstract&holding=f1000,f1000m,isrctn)). However it makes no sense to me why one wouldn't want it on the high TPR region too: at times TPR can be much more important than the FPR. See [Jiang, 1996](http://www.ncbi.nlm.nih.gov/pubmed/8939225?dopt=Abstract&holding=f1000,f1000m,isrctn) who first proposed to do this (afaik).

@karane I would advise against defining it on an interval where both bounds can be changed: it makes the implementation much more tricky, and I haven't seen any case where it is actually useful. Just define it on the TPR interval [0.0, X](and on the FPR interval [X, 1.0]) where only X can be changed. In that case the trapezoid computation is pretty straightforward, most code in the auc function in pROC is there to deal with the multiple edge cases raised by releasing the second bound too.

+1

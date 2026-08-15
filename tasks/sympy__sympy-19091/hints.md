Hi! This is @drybalka.

I totally agree, due to the module design it is impossible to solve this problem without overhaul. Tensor indices contraction is placed inside TensorMul class (for some reason twice, if I’m not mistaken) even though you can have contractions in a single tensor. This code is intertwined with tensor canonicalization and explicit tensor value calculations, which in their turn depend on TensorManager. In short, this is almost all functionality of the tensor module. At some point I noticed I was almost rewriting everything from scratch in order not to lose any functionality. If it was possible, I would have downgraded the module to basics, implemented TensorIndexManager with tensor contractions uniformly both for Tensor and TensorMul, and only then used this functionality to do everything else. However, this is hard to do in one commit and even harder without braking any half-functioning functionality.

I’d be glad to hear your thoughts on this matter because so far I don’t have any progress.

> On 26 Jan 2020, at 04:57, Calvin Jay Ross <notifications@github.com> wrote:
> 
> ﻿
> This is essentially a generalization of #17328.
> 
> The problem in the current implementation is that contractions are handled before applications of the metric, which leads to incorrect results such as in #17328.
> 
> In tensor/tensor.py:
> 
> class Tensor(TensExpr):
> # ...
>     def _extract_data(self, replacement_dict):
>     # ...
>         if len(dum1) > 0:
>             indices2 = other.get_indices()
>             repl = {}
>             for p1, p2 in dum1:
>                 repl[indices2[p2]] = -indices2[p1]
>             other = other.xreplace(repl).doit()
>             array = _TensorDataLazyEvaluator.data_contract_dum([array], dum1, len(indices2))
> 
>         free_ind1 = self.get_free_indices()
>         free_ind2 = other.get_free_indices()
> 
>         return self._match_indices_with_other_tensor(array, free_ind1, free_ind2, replacement_dict)
> And thus, the issue is that _TensorDataLazyEvaluator.data_contract_dum is being called prior to self._match_indices_with_other_tensor (where the metric is applied).
> 
> The reason that this ordering matters is because tensor contraction is itself the abstraction of applying the metric to the tensors that represent psuedo-riemannian manifolds. In essence, it means that we must have it that ; however, this isn't the case here.
> 
> I've tried tampering with the code above, but by the way tensors have been designed, this bug is essentially unavoidable. As a consequence, the tensor module needs to be refactored in order to get accurate results. (Also, the last argument to _TensorDataLazyEvaluator.data_contract_dum isn't used).
> 
> @drybalka, I believe mentioned that he had this sort of refactoring in the works, but based on his fork, progress seems to be slow. I think discussions should be in order for reorganizing how tensors actually represent their components in this module.
> 
> —
> You are receiving this because you were mentioned.
> Reply to this email directly, view it on GitHub, or unsubscribe.

> I’d be glad to hear your thoughts on this matter because so far I don’t have any progress.

I would be totally down for restructuring the module and would be down for collaborating on a pull request. Is anyone in particular in charge of the module? If so, they should definitely have a say; especially if we are going to be potentially breaking any functionality.
@Upabjojr I noticed that you are responsible for the current implementation of `replace_with_arrays`. Do you have any thoughts on this issue?
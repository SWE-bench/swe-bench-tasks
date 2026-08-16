One thought on this: The same `.sqlfluff` file will sometimes be used on different machines (e.g. various development machines, CI server). We should allow the setting to be somewhat "context sensitive" if desired. Proposal:
* Positive values indicate the number of processes to create
* Zero or negative values are interpreted as `number_of_cpus - specified_number`. Thus, a value of `0` means "use all processors" and `-1` means "use all processors except one".
Is there a standard way in python to detect the effective available cpus?
@alanmcruickshank: Yes. Use [`multiprocessing.cpu_count()`](https://docs.python.org/3/library/multiprocessing.html#multiprocessing.cpu_count).
I'm happy to pick this one up. This actually fits with a small reorg of how I think threads should be configured. I think it fits better if the thread argument is passed in to the `Linter` object on instantiation, rather than when calling `lint_paths`. @barrywhart - does that sit well with you? I realise that changes a little of the structure you originally envisaged.
Sounds good -- no concerns from me.
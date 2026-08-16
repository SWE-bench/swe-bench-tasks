I have been wondering for some time why sqlfluff never manages to use 100% of CPU. Running it on my Code base takes about 90 minutes. Though never more than 30% of cpu is used… maybe this sis the reason…
Yeah - this looks like an accurate diagnosis. Most of the testing for the multiprocessing feature was done on large projects of multiple files, but _where a single path was passed_ e.g. `sqlfluff lint .`.

This seems like a very sensible improvement for people using the commit hook.

@barrywhart - you did a lot of the original multiprocessing work. Reckon you could take this one on?
I'll take a look, sure!
We have problems with column reordering in all estimators, but this is the only one where we directly support access by name, so I agree this is a priority to fix. I think raising an error if`columns` differs between fit and transform, and 'remainder' is used, would be a reasonable behaviour. Pull request welcome.
I've marked this to go into 0.20.4, which we hope to release soon to cap off the 0.20.X series. Do other core devs agree?
Good with me
Good with me as well.
Should we deprecate changing the column order in ColumnTransformer? It'll be deprecated (or raise an error?) anywhere else in 0.21 I hope.
I'm currently setting things up locally for contributing a pull request. If it's ok for the core dev team, I would first look into fixing it by remembering the `remainder` transformer's columns as column names (instead of indices) if names are provided. This should in principle fix the issue without needing a column order check (and we would not have to remember the column order somewhere to check it later).
@schuderer For fixing this issue I think that would be good. I'm just concerned that accepting reordered columns here might lead users to believe we accept reordered columns in other places. In fact, they will provide garbage results everywhere else, and I'm sure that leads to many undiscovered bugs.

Cheers,
Andreas ;)
I think we would rather start by being conservative (especially as this
will inform people that their code previously didn't work), and consider
extending it later to be more permissive.

Thank you both for providing this extra context, now I also better understand the rationale behind what jnothman wrote in the first comment and I agree. I'm currently looking at how/where to cleanly do the suggested check with a ValueError. Hope it's okay if it takes a few days (off-hours) as this is my first contribution to a major open source project, and I'm trying to follow the guidelines to the letter.
Edit: I will also check the code documentation to add that columns have to be in the same order when using `remainder`.
Some of those letters you're trying to follow may be out of date. We will
help you through the process in any case. A few days is fine. I think if we
can squeeze this into patch releases for the 0.20 and 0.21 series this
month that would be excellent.

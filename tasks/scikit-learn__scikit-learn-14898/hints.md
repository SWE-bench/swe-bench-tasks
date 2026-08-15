Indeed this is probably the right course of action. Please feel free to open a PR if your wish.
@Sycor4x  I'll gladly work on it if you're not already doing it 
@qdeffense Thank you. I had planned to start these revisions if this suggestion were well-received; however, I've just come down with a cold and won't be able to write coherent code at the moment. If you want to take a stab at this, I support your diligence. 

It occurred to me after I wrote this that it is possible for the verbal description in 3.3.1.1 to be incorrect while the _behavior_ of the scorer objects called via the strings in 3.3.1.1 might work correctly in the sense that internally, `brier_score_loss` behaves in the same manner as `neg_log_loss` and therefore is consistent with the statement

> All scorer objects follow the convention that higher return values are better than lower return values.

If this is the case, then the _documentation_ is the only thing that needs to be tweaked: just make it explicit that some kind of reversal is applied to `brier_score_loss` such that the block quote is true.

I haven't been able to check -- I'm basically incapacitated right now.
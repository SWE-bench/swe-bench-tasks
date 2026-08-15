Unsurprisingly, @raghavrv's PR was forgotten in recent discussion of this. I think we want `force_all_finite='allow-nan'` or =`'-nan'` or similar  
Note: solving #10438 depends on this decision.
Oops! Had not noticed that @glemaitre had started this issue, so was tinkering around with the "allow_nan" and "allow_inf" arguments for check_array() based on a discussion with @jnothman a few months ago. In any case, [here](https://github.com/scikit-learn/scikit-learn/compare/master...ashimb9:checkarray?expand=1) is what I have so far, which might or might not be useful when the discussion here concludes.
Oh sorry about that. I just have ping you on the issue as well.
I will submit what I did yesterday and you can review with what you have in head.
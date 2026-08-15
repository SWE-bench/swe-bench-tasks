I had a look at this.  Although the `LineCollection` docstring states that it “Represents a sequence of Line2Ds”, it doesn’t seem to use the `Line2D` object (unless I’m missing something).

So I think we might need to modify the `Collection.draw` method in an analogous way to how we did the `Line2D.draw` method at #23208.  Though `Collection.draw` is more complicated as it’s obviously supporting a much wider range of cases.

Another possibility might be to modify `LineCollection` itself so that, if _gapgolor_ is set, we add the inverse paths into `LineCollection._paths` (and update`._edgecolors`, `._linestyles` with _gapcolors_ and inverse linestyles).  This would mean that what you get out of e.g. `.get_colors` would be longer than what was put into `.set_colors`, which might not be desirable.

Anyway, for now I just mark this as “medium difficulty”, as I do not think it is a task for a beginner.
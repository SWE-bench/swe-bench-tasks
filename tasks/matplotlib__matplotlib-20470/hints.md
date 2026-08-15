This is an imprecision in the API. Technically, every `Artist` can have a label. But note every `Artist` has a legend handler (which creates the handle to show in the legend, see also https://matplotlib.org/3.3.3/api/legend_handler_api.html#module-matplotlib.legend_handler).

In particular `Text` does not have a legend handler. Also I wouldn't know what should be displayed there - what would you have expected for the text?

I'd tent to say that `Text` just cannot appear in legends and it's an imprecision that it accepts a `label` keyword argument. Maybe we should warn on that, OTOH you *could* write your own legend handler for `Text`, in which case that warning would be a bit annoying.
People can also query an artists label if they want to keep track of it somehow, so labels are not something we should just automatically assume labels are just for legends.
> Technically, every Artist can have a label. But note every Artist has a legend handler

What's confusing is that a `Patch` without a legend handler still appears, as a `Rectangle`, in the legend. I expected a legend entry for the `Text`, not blank output.

> In particular Text does not have a legend handler. Also I wouldn't know what should be displayed there - what would you have expected for the text?

In the non-MWE code I use alphabet letters as "markers". So I expected "A    \<label text\>" to appear in the legend.

> Maybe we should warn on that, OTOH you could write your own legend handler for Text

This is what I did as a workaround.
[Artist.set_label](https://matplotlib.org/devdocs/api/_as_gen/matplotlib.artist.Artist.set_label.html) explicitly specifies 

> Set a label that will be displayed in the legend.

So while you could use it for something else, IMHO it's not in the intended scope and we would not have to care for that.

But thinking about it a bit more: In the current design, Artists don't know if handlers exist for them, so they cannot reasonably warn about that. There's a bit more issues underneath the surface. Overall, while it's a bit annoying as is, we cannot make this better without internal and possibly public API changes.

> In the non-MWE code I use alphabet letters as "markers". So I expected "A <label text>" to appear in the legend.

I see. Given that this only makes sense for special usecases where texts are one or a few characters, I don't think that we can add a reasonable general legend handler for `Text`s. You solution to write your own handler seems the right one for this kind of problem. I'll therefore close the issue (please report back if you think that there should be some better solution, and you have an idea how that can reasonably work for arbitrary texts). Anyway, thanks for opening the issue. 
BTW you can use arbitrary latex strings as markers with `plt.scatter`, something like

```python
plt.scatter(.5, .9, marker="$a$", label="the letter a")
plt.legend()
```

might give what you want.
> Artists don't know if handlers exist for them, so they cannot reasonably warn about that. There's a bit more issues underneath the surface. Overall, while it's a bit annoying as is, we cannot make this better without internal and possibly public API changes.

We could warn when collecting all artists that have handlers (in `_get_legend_handles`) if `has_handler` returns False.  I make no judgment as to whether we want to do that, though.
> We could warn when collecting all artists that have handlers (in `_get_legend_handles`) if `has_handler` returns False.  I make no judgment as to whether we want to do that, though.

Seems cleaner to me. It may be considered an error if a label is set, but that Artist cannot occur in a legend.

This requires looping through all artists instead of https://github.com/matplotlib/matplotlib/blob/93649f830c4ae428701d4f02ecd64d19da1d5a06/lib/matplotlib/legend.py#L1117.
> (please report back if you think that there should be some better solution, and you have an idea how that can reasonably work for arbitrary texts)

This is my custom class:

```python
class HandlerText:
    def legend_artist(self, legend, orig_handle, fontsize, handlebox):
        x0, y0 = handlebox.xdescent, handlebox.ydescent
        handle_text = Text(x=x0, y=y0, text=orig_handle.get_text())
        handlebox.add_artist(handle_text)
        return handle_text
```

Seems to me that it should work for arbitrary text. Here's a [gist](https://gist.github.com/kdpenner/a16d249ae24ed6496e6f5915e4540b4b). Note that I have to add the `Text` handle and label manually.

> We could warn when collecting all artists that have handlers (in _get_legend_handles) if has_handler returns False.

Yes x 1000. It's bewildering to create an `Ellipse` and get a `Rectangle` in the legend. Before I descended into the legend mine, my first thought was not "The `Ellipse` must not have a handler", it was "matplotlib must have a bug". And then it's bewildering again to have `Text` dropped from the legend instead of having a placeholder like in the patches case.
Also I'm willing to work on addition of the warning and/or handler after y'all decide what's best to do.
> Also I'm willing to work on addition of the warning and/or handler.

Great! :+1: 

Please give me a bit of time to think about what exactly should be done.
I'm revisiting my backlog of issues...any more thoughts?
### No default legend handler for Text.
The proposed implmentation is rather tautological, that's something only reasonable in very special cases. I also don't see any other good way to visualize a legend entry for a text.

#### Recommendation: Users should implement their own handler if needed.

### Warn on legend entries without handler.
> We could warn when collecting all artists that have handlers (in _get_legend_handles) if has_handler returns False.

What are the use cases and how would a warning affect them?

1) When using `legend(handles=artists)`, it would be awkward if something in `artists` is silently not rendered because it has no handler. --> warning is reasonable
2) When using `plt.text(..., label='a'), plt.legend()` it deprends:
   a) is the label setting done with the intention of legend? --> then reasonable
   b) is the label only used as a generic identifier? --> then a warning would be unhelpful.

Overall, since the label parameter is bound to taking part in legends, we can dismiss scenario 2b). (With the logic of 2b we'd also get undesired entries in the legend for artists that have a handler.

#### Recommendation: Implement the warning.


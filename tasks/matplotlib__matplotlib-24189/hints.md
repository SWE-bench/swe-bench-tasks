I advocate that passing these kwargs to nested definitions is simply a bug. We should only apply them to the outermost grid. - Typically it does not make sense to use the same parameters for inner definitions even if they are compatible.

Defining parameters for inner layouts might be added later by supporting nested datastructures for *gridspec_kw*. *width_ratios* / *height_ratios* are only a convenience layer and don't need to handle complex cases such as passing parameters to inner layouts.
Marking as good first issue.

Things to do:
- do not pass `width_ratios`, `height_ratios` to nested layouts
- document this in the parameter descriptions
- add a test: `subplot_mosaic([['A', [['B', 'C']]]], width_ratios=[2, 1])` should be good. You can check that the width ratios of the outer layout is [2, 1] but of the inner is not.
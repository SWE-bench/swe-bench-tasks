It looks like internally matplotlib uses `'solid': (0, None)` which is fine, I can switch our code to that -- but it seems like for backward compat supporting `'solid': (0, ())` as an alias would make sense since it used to be that way in official examples (here from 2.x):

https://github.com/matplotlib/matplotlib/blob/908d23d5975d4f4a4c7eb85a057be069700c5a98/examples/lines_bars_and_markers/linestyles.py#L14

Sure, we should still accept `(0, ())` and `(0, [])`.
Okay, I can open a quick PR to fix this
Naming suggestion: `callbacks_disabled()` or even only `disabled()`:
```
with self.norm.callbacks.disabled():
```

In Qt, this is `Widget->blockSignals`, and in GTK, it is `g_signal_handlers_block_*`. Wx has a `wxEventBlocker` that you add on a widget to temporarily stop events. Not sure if Tk has anything similar.

IOW, it seems like 'block' is the common term for this for events, though I don't know if these callbacks qualify as 'events'.
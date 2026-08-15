I think we put some option in the global configuration namespace but the name is now misleading and should be something like "ignore-import-for-similarity" Edit: It's not has bad as I thought we're still talking about the similarity checker here..
I think I know what is causing this. `set_option` of `Similar` sets the options from `.config` to an attribute of the checker. This allows running `Similar` standalone as it no longer requires a `linter.config` object.
With `optparse` `set_option` got called all the time (which is one of the things we wanted to avoid in `argparse`).

However, I think we might be calling it a little too little now. I'll assign myself, although I'm not sure if I can fix this before the weekend. 
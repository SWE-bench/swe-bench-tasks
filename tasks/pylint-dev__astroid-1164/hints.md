This is caused by our local plugin.

Has probably nothing to do with upstream. 
This is caused by a bad refactor from us, we deprecated `astroid.node_classes` and `astroid.scoped_nodes` in favor of `astroid.nodes` but nothing should break before astroid 3.0.
@Pierre-Sassoulas I see.
Also Statement is not available in astroid.nodes it is in astroid.nodes.node_classes

Was the Statement also deprecated? Or called something else now?
It seems we're not using it ourselves or not by using `astroid.nodes` API so we did not realize it was not importable easily. But it should, I'm going to add it.
_From Takayuki Shimizukawa on 2013-12-08 04:41:21+00:00_

New URL: https://github.com/okfn/opendatahandbook/blob/master/Makefile#L114

I think we need new conf.py option like `gettext_mode` it takes values as `file`, `directory` and `all`, and would be better to deprecate `gettext_compact` option.

_From Markus Zapke-Gründemann on 2013-12-08 23:03:55+00:00_

At PyCon DE 2013 we discussed this at the sprints: Our proposol was:

If `gettext_compact` is set to a string instead of a boolean the string is used as catalog name and all translations go into this file.

This wouldn't break existing configurations and does not introduce a new option.

_From Takayuki Shimizukawa on 2014-07-29 06:00:39+00:00_

Let's implement!

Note: I don't think `gettext_compact` will have True/False/<string> is good idea because we might implement "type check for conf.py parameter" in near future [1]. I think we should provide new parameter for the additional purpose (or move to new parameter and obsolete the `gettext_compact`).

.. [1] https://github.com/sphinx-doc/testing/issues/1150#comment-7700104

_From Robert Lehmann on 2014-07-29 07:41:42+00:00_

I think `gettext_compact` could just become an integer (which is backwards-compatible) to signal the new, third behaviour.

I have a patch ready for Markus' proposal but, as you mentioned, Sphinx _already does_ cast values into permissible types, so having a bool/string does not work.  We could find some clever way around this in `conf.py`.

_From Takayuki Shimizukawa on 2014-09-28 14:05:35+00:00_

I'm thinking about 'compatibility', 'sphinx config type check' and 'understandability'. 
- Taking True/False/<filename> by gettext_compact is not intuitive, it has compatibility.
- For now, new config parameter name for new purpose doesn't come up in my mind. I think bad name decrease understandability.
- Sphinx config type check is not implemented yet. In near feature, it will be implemented with backward-compatibility for 3rd-party extensions. It means 'gettext_compact' can be excluded for type checking.

Under these circumstances, I think we should move forward with keeping backward-compatibility and with the least effort.

And so, [Robert Lehmann](https://bitbucket.org/lehmannro), can you commit (or pull request or attach) your patch?

See:
https://github.com/PyCQA/pylint/pull/5315#discussion_r749716016

You are likely loading the extension twice because the only effect of loading `check_docs` is to load the `docparams` extension.
> You are likely loading the extension twice because the only effect of loading `check_docs` is to load the `docparams` extension.

Probably the problem is `--list-extensions` lists BOTH `check_docs` AND `docparams`, probably `--enable-all-extensions` does the same mistake.

```
$ pylint --list-extensions  | sort
pylint.extensions.bad_builtin
pylint.extensions.broad_try_clause
pylint.extensions.check_docs
pylint.extensions.check_elif
pylint.extensions.code_style
pylint.extensions.comparetozero
pylint.extensions.comparison_placement
pylint.extensions.confusing_elif
pylint.extensions.consider_ternary_expression
pylint.extensions.docparams
pylint.extensions.docstyle
pylint.extensions.empty_comment
pylint.extensions.emptystring
pylint.extensions.for_any_all
pylint.extensions.mccabe
pylint.extensions.overlapping_exceptions
pylint.extensions.redefined_variable_type
pylint.extensions.set_membership
pylint.extensions.typing
pylint.extensions.while_used
```
Yes @jolaf this is what caused the problem, I wanted to use all extensions in my configuration.
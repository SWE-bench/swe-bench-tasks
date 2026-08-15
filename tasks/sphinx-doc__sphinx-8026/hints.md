BTW the fact that `{root}` and `{path}` are absolute might be a bug, given that the code reads like `translated` would be supposed to be relative to the doc file:
https://github.com/sphinx-doc/sphinx/blob/3.x/sphinx/util/i18n.py#L318-L327

Yet on my system with Sphinx 1.8.5 the variables would be:
```
srcdir: /home/akien/Projects/godot/godot-docs-l10n/docs
dirname: getting_started/step_by_step
translated: /home/akien/Projects/godot/godot-docs-l10n/docs/getting_started/step_by_step/img/shooter_instancing.fr.png
```
`path.join` seems to be happy to automatically resolve the concatenation of the two absolute paths, which is why it works fine as is.

If this were changed so that the output of `get_image_filename_for_language(filename, env)` is made relative to the doc name, I would still need an extra token for my use case as I'd need to have the `dirname` part too from the above code link (`path.dirname(env.docname)`).
Thank you for reporting. I agree this is a bug. And it seems the configuration was designed as `{root}` is a relative path from the current document (Our document says `dirname/filename` is a root token for `dirname/filename.png`!).

>{root} - the filename, including any path component, without the file extension, e.g. dirname/filename

I'll try to fix this not to cause breaking changes later.
Sounds good. Making `{root}` and `{path}` relative to the current document and thus matching their documentation definitely makes sense.

For the other, feature proposal part of this issue, I'd suggest to then consider adding a new token that would be basically `path.join(path.dirname(env.docname), {path}` (with `{path}` being the actual Python variable used to format it). As in my use case having only the path relative to the current document wouldn't be sufficient, since `figure_language_filename` doesn't provide any reference to what the current document is.
As a first step, I just posted #8006 to fix that an absolute path is passed to `figure_language_filename` as a `{root}`.

Now I'm considering about next step, adding a new key for `figure_language_filename`.
@akien-mga I'd like to confirm just in case, what you want is a dirname of the document, right? If so, I will add a new key like `docpath` (I'm still looking for more better name for this).
Thanks for the bugfix!

Yeah, I think what I'd need would be a dirname of the document, and possibly always resolved to be relative to the root folder of the project, e.g. with:
```
community/contributing/img/l10n_01_language_list.png
```
Referenced in:
```
community/contributing/editor_and_docs_localization.rst
```
as:
```
.. image:: img/l10n_01_language_list.png
```
I'd need to have access somehow to:
```
community/contributing/img
```
So that the `figure_language_filename` can be configured as:
```
<arbitrary path>/{docpath}/{filename}.{language}{extension}
```

In my concrete example, this would resolve to (`..` is a separated l10n repo where the main Sphinx project is included as submodule, see https://github.com/godotengine/godot-docs-l10n):
```
../images/community/contributing/img/l10n_01_language_list.fr.png
```
for example (French locale).

Currently I'm monkey-patching Sphinx this way and it works fine for the use case, though of course I'm looking forward to using an upstream solution :)
https://github.com/godotengine/godot-docs/blob/04f7c48b90d5a3573486e631ddf665b61d971ac1/conf.py#L204-L231
I just merged #8006 now. And I'll add `docpath` later.
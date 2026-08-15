The problem seems to be in `utils.expand_modules()` in which we find the code that actually performs the ignoring:

```python
if os.path.basename(something) in black_list:
    continue
if _basename_in_blacklist_re(os.path.basename(something), black_list_re):
    continue
```
Here `something` will be of the form `"stuff/b.py"` and `os.path.basename(something)` will be of the form `b.py`. In other words, _before_ we do the ignoring, we specifically remove from the filepath all of the information about what directory it's in, so that it's impossible to have any way of ignoring a directory. Is this the intended behavior?
Hi @geajack Thanks for reporting an issue. That behaviour it's probably not intended, I think we definitely need to fix this to allow ignoring directories as well.
@geajack  @PCManticore Is there a work around to force pylint to ignore directories?  I've tried `ignore`, `ignored-modules`, and `ignore-patterns` and not getting to a working solution.  Background is I want to pylint scan source repositories (during our TravisCI PR builds), but want to exclude any python source found in certain directories: specifically directories brought in using git-submodules (as those submodules are already covered by their own TravisCI builds).  Would like to set something in the project's `.pylintrc` that would configure pylint to ignore those directories...
Has there been any progress on this issue? It's still apparent in `pylint 2.3.1`.
@bgehman Right now ignoring directories is not supported, as per this issue suggests. We should add support for ignoring directories to `--ignore` and `--ignore-patterns`, while `--ignored-modules` does something else entirely (ignores modules from being type checked, not completely analysed).

@Michionlion There was no progress on this issue, as you can see there are 400 issues opened, so depending on my time, it's entirely possible that an issue could stay open for months or years. Feel free to tackle a PR if you need this fixed sooner.
Relates to #2541
I also meet this problem.
Can we check path directly? I think it's more convenient for usage.
workaround... add this to your .pylintrc:

```
init-hook=
    sys.path.append(os.getcwd());
    from pylint_ignore import PylintIgnorePaths;
    PylintIgnorePaths('my/thirdparty/subdir', 'my/other/badcode')
```

then create `pylint_ignore.py`:

```
from pylint.utils import utils


class PylintIgnorePaths:
    def __init__(self, *paths):
        self.paths = paths
        self.original_expand_modules = utils.expand_modules
        utils.expand_modules = self.patched_expand

    def patched_expand(self, *args, **kwargs):
        result, errors = self.original_expand_modules(*args, **kwargs)

        def keep_item(item):
            if any(1 for path in self.paths if item['path'].startswith(path)):
                return False

            return True

        result = list(filter(keep_item, result))

        return result, errors
When will we get a fix for this issue?
This is still broken, one and a half year later... The documentation still claims that these parameters can ignore directories.

This is currently functioning as expected in that it only looks for `.sqlfluffignore` files within the directories you specify. So if you point sqlfluff at `/path_b`, it would only looks for a `.sqlfluffignore` file at `/path_b/.sqlfluffignore` and any child directories of that. It won't check in parents of the given file.

I think that's the expected behavior consistent with `.dockerignore` and `.gitignore` .

I agree about clarifying the documentation, which uses the phrase `placed in the root of your project` which I think alone is misleading.
I think the behavior described in this issue is desirable.

For CI with pre-commit for example, right now I would need to add a `.sqlfluffignore` to each sub-directory containing sql files I want to ignore. That's because pre-commit will give the full path pointing to each file that changed before commit.

I'm not sure the behavior is consistent with `.gitignore` because the "project root" stays the same and `.gitignore` files are applied from top level down to the subdirectory of each file, while in `sqlfluff` we don't really have a project root, which I think could come from a new configuration in `.sqlfluff` (or we could assume `cwd` if it's parent directory of the file we're trying to lint).
I've just hit this issue myself (but for configuration file) and I agree with @dmateusp on this one.

I think this is more than a documentation issue.

From putting together the initial configuration code, the config loader, *should* check the current working directory for config loading, but it feels like that isn't working right now.
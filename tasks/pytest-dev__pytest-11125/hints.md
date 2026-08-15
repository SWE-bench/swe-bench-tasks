a recent bugfix made a hidden mistake in your conftest layout surface

the basic gist is, that with testpaths, pytest now correctly consider the conf-tests in those root test paths as possible early loaded conftests (to supply addopts & co) in turn making sure that all options are always registred

as far as i understand you previously ran either one or the other parts of the testsuite, thus it was never possible that both conftests where loaded at the same time (which was a bug in pytest)

now that pytest more correctly considers all sources of options, an error pops up as previously you actually absolutely had to register in both places since pytest was not picking up all sources of options for a testsuite 

the recommended fix would be to move shared options into a plugin module to list it in the pytest_plugins of the conftests


thank you for the clarification! that does make sense, it's true that we never seemed to run both test suites together, we'd always do `pytest unit_test` or `pytest test` so the config was never perfect.

I'll close this out, as it looks to me that the solution is for us to fix our config.
`testpaths` is a fallback for when no arguments are given; if the two directories in your `testpaths` are incompatible, that means the value doesn't make sense so you should just remove your `testpaths`.

---

However, I do think there's an issue in pytest here. `testpaths` is only supposed to be a fallback for the arguments, however #10988 endowed it with further semantics, which increases the complexity and causes problems such as this one.

I think that if argument paths are to be used for finding initial conftests, then we should use the `config.args` (the result of choosing between command line args, testpaths, invocation dir) rather than `testpaths` directly.

@nicoddemus WDYT? (Reopening for discussion)
> However, I do think there's an issue in pytest here. testpaths is only supposed to be a fallback for the arguments, however https://github.com/pytest-dev/pytest/pull/10988 endowed it with further semantics, which increases the complexity and causes problems such as this one.

You are right, I did not realize that at the time.

>  think that if argument paths are to be used for finding initial conftests, then we should use the config.args (the result of choosing between command line args, testpaths, invocation dir) rather than testpaths directly.

At first glance seems reasonable indeed.
Agreed this seems a fundamental change in behavior in how `testpaths` config is treated.  It's an optional fallback only used for test collection when no file paths are provided. But. it now always forces the pytest to load conftests pointed to by the root-level configured `testpaths`even when a specific file or directory of tests is provided. This breaks a paradigm where separate apps or integration tests versus unittests in a single project may have a different set of test dependencies pulled in by their `conftest`s.

Is it desirable that the solution in #10988 should also treat `testpaths` only as an optional fallback value when namespace.file_or_dir is unset in ` _set_initial_conftests` [instead of always appending the value](https://github.com/pytest-dev/pytest/pull/10988/files#diff-df52f8f6a3544754cc8ebdf903594738e68a18dc9ac3c959f646cf4705a9afedR549)?

What do we think of something like this?
```diff
diff --git a/src/_pytest/config/__init__.py b/src/_pytest/config/__init__.py
index 85d8830e7..fa1924ce5 100644
--- a/src/_pytest/config/__init__.py
+++ b/src/_pytest/config/__init__.py
@@ -546,7 +546,10 @@ class PytestPluginManager(PluginManager):
         )
         self._noconftest = namespace.noconftest
         self._using_pyargs = namespace.pyargs
-        testpaths = namespace.file_or_dir + testpaths_ini
+        testpaths = namespace.file_or_dir
+        if not testpaths:
+            # source testpaths_ini value only when command-line files absent
+            testpaths = testpaths_ini
         foundanchor = False
         for testpath in testpaths:
             path = str(testpath)
```
 

If folks believe that new `conftest` search behavior from #10988 should be retained as-is maybe we can [document the testpaths treatment for conftest search path treatment more conspicuously in docs](https://docs.pytest.org/en/7.1.x/reference/reference.html?highlight=testpaths#confval-testpaths)

Thanks for the extra details

I consider this a overreaching bugfix

We should restore part of the old behavior until a major release

We also should ensure all test path related conftests are considered for pytest configuration and addoption for consistency in a major release 
Agreed.

Sorry I won't be able to work on this today (likely tomorrow), so if anybody wants to contribute a fix, it would be greatly appreciated!
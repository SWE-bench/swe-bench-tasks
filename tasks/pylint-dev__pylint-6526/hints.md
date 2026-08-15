One thing that could prevent using the XDG_HOME is if an env var for PYLINTHOME exists.

Relevant code:
https://github.com/PyCQA/pylint/blob/main/pylint/constants.py#L54
https://github.com/PyCQA/pylint/blob/main/pylint/config/__init__.py#L39
Another issue might be that by using `stdin` the `FileItem` used by our main `PyLinter` class has a non-sensical file name.
That file name is used by the following function to determine a part of the file to be saved to:
https://github.com/PyCQA/pylint/blob/ae5ed5c57a8f9a60a37bd010be052b08aa864de7/pylint/lint/pylinter.py#L1038

I followed the mentioned topic somewhat but haven't fully kept up. Is there an easily reproducible example? I'd be happy to try and investigate what is happening inside `save_results`.
```diff
diff --git a/pylint/config/__init__.py b/pylint/config/__init__.py
index b8fb0a0b..87b9ef24 100644
--- a/pylint/config/__init__.py
+++ b/pylint/config/__init__.py
@@ -95,12 +95,15 @@ def load_results(base):
 
 
 def save_results(results, base):
+    print(base)
+    print(PYLINT_HOME)
     if not os.path.exists(PYLINT_HOME):
         try:
             os.makedirs(PYLINT_HOME)
         except OSError:
             print(f"Unable to create directory {PYLINT_HOME}", file=sys.stderr)
     data_file = _get_pdata_path(base, 1)
+    print(data_file)
     try:
         with open(data_file, "wb") as stream:
             pickle.dump(results, stream)
```

Could also help investigate some of the variables within that function.
@DanielNoord @Pierre-Sassoulas Thanks for the input, I will try and look into it.

for the minimal repro, unfortunately we have not been able to narrow down the parameters that cause. It seems to be specific to the permissions and how the server hosting pylint itself is launched. The information above might help narrow this down.
@karthiknadig Feel free to ping me in the other issue if needed! I'd be glad to provide any other diffs or fix-branches that might solve the issue. From what I gathered from the discussion until now it is still not clear whether the issue is with the user, the extension or pylint's internals. Happy to help narrow that down!
I have opened the issue for the extension. I think I found the reason (https://github.com/microsoft/vscode-pylint/issues/30#issuecomment-1103733138) and there is now a reproducible example (https://github.com/microsoft/vscode-pylint/issues/30#issuecomment-1102970279).
Just to update: I have been working on a fix in https://github.com/DanielNoord/pylint/pull/135. I just need to test with the original reporter once more if this does indeed work and then I'll submit the patch.
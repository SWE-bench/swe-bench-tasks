Same behaviour when logging from `pytest_configure()`.
Hi! I'm a first-time contributor and would like to work on this issue. Do You any suggestions on how to tackle this?
You could start by reproducing the issue on your machine.

Interestingly, the issue does not occur when `--log-cli-level` is set to at least WARN:
```
pytest --log-cli-level=WARNING test_logging.py
======================================= test session starts ========================================
platform linux -- Python 3.7.5, pytest-5.3.0, py-1.8.0, pluggy-0.13.1
rootdir: /home/felix/src/pytest
collecting ... 
--------------------------------------- live log collection ----------------------------------------
WARNING  root:test_logging.py:7 _check_cond
collected 1 item                                                                                   

test_logging.py::test_logging 
------------------------------------------ live log call -------------------------------------------
WARNING  root:test_logging.py:13 Schmift
FAILED                                                                                       [100%]

============================================= FAILURES =============================================
___________________________________________ test_logging ___________________________________________

    @pytest.mark.skipif(not _check_cond(), reason="_check_cond not met")
    def test_logging():
        logging.warning("Schmift")
    
>       assert False
E       assert False

test_logging.py:15: AssertionError
---------------------------------------- Captured log call -----------------------------------------
WARNING  root:test_logging.py:13 Schmift
======================================== 1 failed in 0.03s =========================================
```

One possibility would be to see what's different with `--log-cli-level` set, but I have no idea whether that's the right track.
I assume this happens because logging gets setup while pytest is capturing, and therefore sees pytest's redirected stderr.
See also https://github.com/pytest-dev/pytest/issues/5997#issuecomment-552194863.
This appears to fix it:
```diff
diff --git a/src/_pytest/logging.py b/src/_pytest/logging.py
index ccd79b834..04cae12d8 100644
--- a/src/_pytest/logging.py
+++ b/src/_pytest/logging.py
@@ -7,6 +7,7 @@
 from typing import Dict
 from typing import List
 from typing import Mapping
+from typing import Optional
 
 import pytest
 from _pytest.compat import nullcontext
@@ -260,10 +261,13 @@ def add_option_ini(option, dest, default=None, type=None, **kwargs):
 
 
 @contextmanager
-def catching_logs(handler, formatter=None, level=None):
+def catching_logs(handler: Optional["LogCaptureHandler"], formatter=None, level=None):
     """Context manager that prepares the whole logging machinery properly."""
     root_logger = logging.getLogger()
 
+    if handler is None:
+        handler = LogCaptureHandler()
+
     if formatter is not None:
         handler.setFormatter(formatter)
     if level is not None:
@@ -596,10 +600,7 @@ def pytest_collection(self):
             if self.log_cli_handler:
                 self.log_cli_handler.set_when("collection")
 
-            if self.log_file_handler is not None:
-                with catching_logs(self.log_file_handler, level=self.log_file_level):
-                    yield
-            else:
+            with catching_logs(self.log_file_handler, level=self.log_file_level):
                 yield
 
     @contextmanager
```

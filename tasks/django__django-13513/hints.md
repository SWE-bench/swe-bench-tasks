Here is a related (but different) issue about the traceback shown by the debug error view ("debug error view shows no traceback if exc.traceback is None for innermost exception"): https://code.djangoproject.com/ticket/31672
Thanks Chris. Would you like to prepare a patch?
PR: ​https://github.com/django/django/pull/13176
Fixed in f36862b69c3325da8ba6892a6057bbd9470efd70.
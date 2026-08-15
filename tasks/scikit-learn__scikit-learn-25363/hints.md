Thinking more about it, we could also make this more automatic by subclassing `joblib.Parallel` as `sklearn.fixes.Parallel` to overried the `Parallel.__call__` method to automatically call `sklearn.get_config` there and then rewrap the generator args of `Parallel.__call__` to call `delayed_object.set_config(config)` on each task.

That would mandate using the `sklearn.fixes.Parallel` subclass everywhere though.

And indeed, maybe we should consider those tools (`Parallel` and `delayed`) semi-public with proper docstrings to explain how they extend the joblib equivalent to propagate scikit-learn specific configuration to worker threads and processes.
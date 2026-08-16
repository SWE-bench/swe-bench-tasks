error during inference of class inheriting from another with `mod.Type` format
Consider package a `level` with a class `Model` defined in `level`'s `__init__.py` file.

```
class Model:
    data: int = 1
```

If a class `Test` inherits from `Model` as `class Test(Model)`, and `Model` comes from `from level import Model`,  then inferring `Test.data` works fine (below, A is an alias for astroid).

<img width="248" alt="Screen Shot 2021-02-19 at 09 41 09" src="https://user-images.githubusercontent.com/2905588/108505730-9b3c1900-7296-11eb-8bb8-5b66b7253cf4.png">

However, if a `Test` inherits from `Model` as `class Test(level.Model)` and `level` comes from `import level`, then inference triggers an exception.

<img width="784" alt="Screen Shot 2021-02-19 at 09 42 09" src="https://user-images.githubusercontent.com/2905588/108505815-beff5f00-7296-11eb-92a2-641be827e1f0.png">






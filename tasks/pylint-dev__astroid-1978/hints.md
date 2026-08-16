This seems very similar to https://github.com/PyCQA/astroid/pull/1514 that was fixed in 2.12.0.
I'm running 2.12.13 (> 2.12.0), so the fix isn't working in this case?
I don't know why #1514 did not fix this, I think we were capturing both stdout and stderr, so this will need some investigation. My guess would be that there's somewhere else to apply the same method to.
Hello, 
I see the same error with pylint on our tool [demcompare](https://github.com/CNES/demcompare). Pylint version:
```
pylint --version
pylint 2.15.9
astroid 2.12.13
Python 3.8.10 (default, Nov 14 2022, 12:59:47) 
[GCC 9.4.0]
```
I confirm the weird astroid lower warning and I don't know how to bypass it with pylint checking. 

```
pylint demcompare 
/home/duboise/work/src/demcompare/venv/lib/python3.8/site-packages/astroid/raw_building.py:470: FutureWarning: In the future `np.long` will be defined as the corresponding NumPy scalar.  (This may have returned Python scalars in past versions.
  getattr(sys.modules[modname], name)
... (four times)
```

Thanks in advance if there is a solution
Cordially

> Thanks in advance if there is a solution

while annoying the warning does not make pylint fail. Just ignore it. In a CI you can just check pylint return code. It will return 0 as expected
I agree, even if annoying because it feels our code as a problem somewhere, the CI with pylint doesn't fail indeed. Thanks for the answer that confirm to not bother for now. 
That might be fine in a CI environment, but for users, ultimately, ignoring warnings becomes difficult when there are too many such warnings. I would like to see this fixed.
Oh, it was not an argument in favour of not fixing it. It was just to point out that it is not a breaking problem. It is "just" a lot of quite annoying warnings. I am following the issue because it annoys me too. So I am in the same "I hope they will fix it" boat
> I don't know why https://github.com/PyCQA/astroid/pull/1514 did not fix this, I think we were capturing both stdout and stderr, so this will need some investigation. My guess would be that there's somewhere else to apply the same method to.

That PR only addressed import-time. This `FutureWarning` is emitted by numpy's package-level `__getattr__` method, not during import.
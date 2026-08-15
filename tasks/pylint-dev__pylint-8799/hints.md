Hello, are you using any particular libraries or code construct ? As it is it's going to be impossible to reproduce. 
The gpt4free repository was cloned in this project, I added it to ignore in the .pylintrc file. This reduced the running time by only 2 seconds.
Checking the file with "\n":
```sh
$ echo "\n" > test.py && time pylint test.py
************* Module test
test.py:1:2: E0001: Parsing failed: 'unexpected character after line continuation character (<unknown>, line 1)' (syntax-error)

real    0m1.639s
user    0m0.000s
sys     0m0.015s
```
Checking the bot file (150 lines):
```sh
$time pylint main.py
************* Module main
main.py:137:7: R0133: Comparison between constants: '0 == 1' has a constant value (comparison-of-constants)
main.py:147:0: C0116: Missing function or method docstring (missing-function-docstring)

------------------------------------------------------------------
Your code has been rated at 9.57/10 (previous run: 9.57/10, +0.00)


real    0m6.689s
user    0m0.000s
sys     0m0.031s
```
There are no big files in the working directory.
I created an empty file in empty folder, here is the output of pylint:
```sh
$ mkdir pylint-testing && cd pylint-testing

$ touch test.py

$ time pylint test.py --disable=all

real    0m1.616s
user    0m0.000s
sys     0m0.015s

$ time pylint test.py

real    0m1.592s
user    0m0.000s
sys     0m0.000s
```
I don't think it's a problem of specific libraries. If you want me to share any logs or traces with you, let me know.
I tested my code with flake8 and pycodestyle (aka pep8). There are results:
```sh
$ time flake8 main.py
main.py:27:80: E501 line too long (80 > 79 characters)
main.py:66:80: E501 line too long (82 > 79 characters)
main.py:80:80: E501 line too long (88 > 79 characters)
main.py:97:80: E501 line too long (81 > 79 characters)
main.py:114:67: E261 at least two spaces before inline comment
main.py:114:80: E501 line too long (111 > 79 characters)
main.py:118:80: E501 line too long (83 > 79 characters)
main.py:123:67: E261 at least two spaces before inline comment
main.py:123:80: E501 line too long (111 > 79 characters)
main.py:125:80: E501 line too long (85 > 79 characters)
main.py:127:80: E501 line too long (88 > 79 characters)
main.py:135:80: E501 line too long (98 > 79 characters)
main.py:137:15: E261 at least two spaces before inline comment
main.py:143:80: E501 line too long (82 > 79 characters)

real    0m0.673s
user    0m0.000s
sys     0m0.000s
```

```sh
$ time pycodestyle main.py
main.py:27:80: E501 line too long (80 > 79 characters)
main.py:66:80: E501 line too long (82 > 79 characters)
main.py:80:80: E501 line too long (88 > 79 characters)
main.py:97:80: E501 line too long (81 > 79 characters)
main.py:114:67: E261 at least two spaces before inline comment
main.py:114:80: E501 line too long (111 > 79 characters)
main.py:118:80: E501 line too long (83 > 79 characters)
main.py:123:67: E261 at least two spaces before inline comment
main.py:123:80: E501 line too long (111 > 79 characters)
main.py:125:80: E501 line too long (85 > 79 characters)
main.py:127:80: E501 line too long (88 > 79 characters)
main.py:135:80: E501 line too long (98 > 79 characters)
main.py:137:15: E261 at least two spaces before inline comment
main.py:143:80: E501 line too long (82 > 79 characters)

real    0m0.301s
user    0m0.015s
sys     0m0.000s
```

I understand that pylint does a deeper analysis, but that shouldn't increase the check time by 6 seconds.
Duplicate of #5933 @Pierre-Sassoulas ?
Or https://github.com/pylint-dev/astroid/issues/2161, but I don't think those perf issues are *that* bad so I suppose it's a pathological case on a specific lib / code construct and not a duplicate.
Could you use a profiler like cProfile and post the result? You can profile:

from pylint.lint import Run
Run(["a.py", "disable=all"])


> There are no big files in the working directory.

The size of the files is not material; it's what they import. If you import pandas, pylint is going to parse and replace the AST for pandas. That's going to take some time--it's part of pylint's distinct value proposition versus ruff, flake8, etc.

That said, I've seen a sprinkle of bug reports about `--disable=all` taking non-trivial time, so we may as well short circuit and just print the help message if a user disables everything.
I rescoped it to "short circuit if all checks disabled" to make it actionable, but if you have a specific import statement you can share to advance the investigation, feel free to provide it. Otherwise it would be a duplicate of #5835 or #1416. Thanks.
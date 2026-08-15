Are you sure that pyside6 is installed in the environment that is being used for the terminal.
Yes. In the same interactive shell, I can run the following cell

```python
# %%
import PySide6
print(PySide6.__version__)  # Prints 6.5.0
```
When I start python from the command line and try to plot things, interactive plots work. It's only in VS Code interactive mode, when I try to enable interactive plots with `%matplotlib qt` does this happen.
If you import `pyside6` before you do `%matplotlib qt` does it work?
It does not unfortunately. Just tested in a fresh shell:

```python
# %%
import PySide6
import matplotlib.pyplot as plt

%matplotlib qt
```

```
ImportError: Failed to import any of the following Qt binding modules: PyQt6, PySide6, PyQt5, PySide2
```

I also want to add that this has been happening to me for many months, on two separate machines (Windows 10 and Windows 11).
Can you try the code in https://github.com/matplotlib/matplotlib/blob/bff46815c9b6b2300add1ed25f18b3d788b816de/lib/matplotlib/backends/qt_compat.py#L82-L89 to verify that works as expected?

does `%gui qt` work?

Does

```
import PySide6
import matplotlib.pyplot as plt
plt.ion()
fig, ax = plt.subplots()
```

work?

What version of pyside6?

In the shells where it works can you check

```
fig = plt.gcf() # or get a Figure object however you want
print(type(fig.canvas).mro()
```

to make sure it really is using pyside6 in those cases.

Sorry for asking many questions, I do not have a window system set up to reproduce this.


> Can you try the code in
> 
> https://github.com/matplotlib/matplotlib/blob/bff46815c9b6b2300add1ed25f18b3d788b816de/lib/matplotlib/backends/qt_compat.py#L82-L89
> 
> to verify that works as expected?


This works if I run directly in the shell.

> does `%gui qt` work?

This line runs without exception, but matplotlib would still use the Agg backend.

> 
> Does
> 
> ```
> import PySide6
> import matplotlib.pyplot as plt
> plt.ion()
> fig, ax = plt.subplots()
> ```
> 
> work?

This executes without exception, but the result plot is still `inline`.

> 
> What version of pyside6?

6.5.0

> 
> In the shells where it works can you check
> 
> ```
> fig = plt.gcf() # or get a Figure object however you want
> print(type(fig.canvas).mro()
> ```
> 
> to make sure it really is using pyside6 in those cases.

It's not using the PySide6 backend: `[<class 'matplotlib.backends.backend_agg.FigureCanvasAgg'>, <class 'matplotlib.backend_bases.FigureCanvasBase'>, <class 'object'>]`

> Sorry for asking many questions, I do not have a window system set up to reproduce this.

No I understand. Thanks for your help. I'm an absolute noob with Windows but I need to develop native Windows apps for work :(

Can you get a Pyside6 "hello world" app to work in the vscode terminal?

Another thing I just noticed is that there is "conda" in your paths, but you said you installed via pip.

Try making a fresh environment and installing everything from conda.  Mixing conda and wheels can go bad in odd ways (see https://pypackaging-native.github.io).

Can you try older versions of pyside?  

If you use

```
plt.switch('qtagg')
```

early does that make any difference?
`plt.switch_backend('qtagg')` gave the same error: `ImportError: Failed to import any of the following Qt binding modules: PyQt6, PySide6, PyQt5, PySide2`

In the same VS Code interactive shell, I can run the following hello world program with PySide6 and a Qt window pops up.

```python
from PySide6 import QtWidgets

app = QtWidgets.QApplication()
win = QtWidgets.QWidget()
win.show()
app.exec()
```

This actually isn't specific to Windows and the above results are from an Ubuntu 22.04 machine.
The reason I'm using conda + pip: 

1. Conda is great at managing virtual environments. pip doesn't do that.
2. My packages are all declared with a `pyproject.toml` file. I can then easily install my packages with `pip install .` and have `pip` manage the dependencies for me. I have yet to find a painless way to manage my own packages with `conda`. 

That said, in this case, I'm exclusively using `pip` to manage packages in this environment and only using `conda` as the python version/virtual environment manager, which I heard is innocuous.

Re: mixing conda env and pip - I just took a look, even `matplotlib` (when using `conda` virtual environments) needs to use `pip install -e .` to install `matplotlib`...: https://matplotlib.org/devdocs/devel/development_setup.html#create-a-dedicated-environment
I can not reproduce this (I got the interactive window by right click -> "run in interactive window" on an empty file and selected the system Python (which on my system has enough of the stack installed) for the Python that vscode is using).

Looking at the code in `qt_compat.py` can you sort out exactly what is failing when we try each of the bindings? 
I looked into `qt_compat.py`, and when I execute 

```python
import matplotlib.backends.qt_compat
matplotlib.backends.qt_compat._setup_pyqt5plus()
```

I get the same exception. 

However, I just found a fix! Since I know I'm using `PySide6`, I can run this line https://github.com/matplotlib/matplotlib/blob/bff46815c9b6b2300add1ed25f18b3d788b816de/lib/matplotlib/backends/qt_compat.py#L83 no problem, since `PySide6` has always been installed. Once I do that, the above imports of `qt_compat._setup_pyqt5plus()` works and `%matplotlib qt` works.

```python
from PySide6 import QtCore, QtGui, QtWidgets, __version__
import shiboken6
```
Ok I stepped through `qt_compat.py` with a debugger and found the issue. 

When I run `%matplotlib qt`, mpl loads `qt_compat.py` which in turn executes the file. 



https://github.com/matplotlib/matplotlib/blob/bff46815c9b6b2300add1ed25f18b3d788b816de/lib/matplotlib/backends/qt_compat.py#L39-L46

After this, `QT_API` remains undefined because no Qt bindings have been imported yet. So, we fall through to this case:

https://github.com/matplotlib/matplotlib/blob/bff46815c9b6b2300add1ed25f18b3d788b816de/lib/matplotlib/backends/qt_compat.py#L47-L59

For my environment, `mpl.rcParams._get_backend_or_none()` returns `Qt5Agg`, even though I have no Qt5 bindings installed. Still, we run into this case

https://github.com/matplotlib/matplotlib/blob/bff46815c9b6b2300add1ed25f18b3d788b816de/lib/matplotlib/backends/qt_compat.py#L56

So now, `QT_API = None` and `_QT_FORCE_QT5_BINDING = True`, and we fall though to this case while `_setup_qt5plus()` is never executed. 

https://github.com/matplotlib/matplotlib/blob/bff46815c9b6b2300add1ed25f18b3d788b816de/lib/matplotlib/backends/qt_compat.py#L115 

Obviously, we now get to this line since no Qt5 bindings are installed. 

https://github.com/matplotlib/matplotlib/blob/bff46815c9b6b2300add1ed25f18b3d788b816de/lib/matplotlib/backends/qt_compat.py#L134

My work around of importing `PySide6.QtCore` manually above basically negates this issue because once Qt6 bindings are in `sys.modules`, `qt_compat.py` would set `QT_API = QT_API_PYSIDE6`.
On a first pass look, it seems for me this is caused by https://github.com/matplotlib/matplotlib/blob/bff46815c9b6b2300add1ed25f18b3d788b816de/lib/matplotlib/backends/qt_compat.py#L56

which if I check git blame, you committed https://github.com/matplotlib/matplotlib/commit/2bc0c1c4b97d00c0f6e849f799cc9a670a736238 

So the question is: is this line of forcing Qt5 causing this bug, or is it the fact that MPL is using `Qt5Agg` in my environment when I only have `Qt6` bindings installed the problem? Am not familiar with `Agg` backends and what they mean so would love your input
> For my environment, mpl.rcParams._get_backend_or_none() returns Qt5Agg, even though I have no Qt5 bindings installed.


This says something in your system is setting the backend to 'qt5agg' which we take to mean "I want to us Qt5" (see https://github.com/matplotlib/matplotlib/pull/22005 and the linked issuse).  Is there something in your environment forcing the backend to `'qt5agg'`? Could be an `matplotlibrc` or a `mpl.use` in a start up script.

The bug to fix here is that if we are restricting to Qt5 then the error message should not list the Qt6 bindings!

I doubt its an environment issue, since I can reproduce this problem on 3 separate machines (Windows 10, Windows 11, Ubuntu 22.04) with a clean conda environment. Could you point me to how mpl selects the default backend? I'm curious to see where in code MPL decides to use the `Qt5Agg` backend by default. I just tested again in a clean conda environment on Windows 10, with just `matplotlib` and `PySide6` installed, and trying `%matplotlib qt` still gives me that exception. Here's my pip list

```
(test) PS C:\Users\tnie\code\tmp> pip list
Package                       Version
----------------------------- -------
asttokens                     2.2.1
backcall                      0.2.0
backports.functools-lru-cache 1.6.4
colorama                      0.4.6
contourpy                     1.0.7
cycler                        0.11.0
debugpy                       1.5.1
decorator                     5.1.1
executing                     1.2.0
fonttools                     4.39.3
importlib-metadata            6.6.0
ipykernel                     6.15.0
ipython                       8.12.0
jedi                          0.18.2
jupyter_client                8.2.0
jupyter_core                  5.3.0
kiwisolver                    1.4.4
matplotlib                    3.7.1
matplotlib-inline             0.1.6
nest-asyncio                  1.5.6
numpy                         1.24.3
packaging                     23.1
parso                         0.8.3
pickleshare                   0.7.5
Pillow                        9.5.0
pip                           23.0.1
platformdirs                  3.3.0
prompt-toolkit                3.0.38
psutil                        5.9.0
pure-eval                     0.2.2
Pygments                      2.15.1
pyparsing                     3.0.9
PySide6                       6.5.0
PySide6-Addons                6.5.0
PySide6-Essentials            6.5.0
python-dateutil               2.8.2
pywin32                       305.1
pyzmq                         23.2.0
setuptools                    66.0.0
shiboken6                     6.5.0
six                           1.16.0
stack-data                    0.6.2
tornado                       6.2
traitlets                     5.9.0
typing_extensions             4.5.0
wcwidth                       0.2.6
wheel                         0.38.4
zipp                          3.15.0
```
> I'm curious to see where in code MPL decides to use the Qt5Agg backend by default. 

It should not, https://github.com/matplotlib/matplotlib/blob/b3bd929cf07ea35479fded8f739126ccc39edd6d/lib/matplotlib/pyplot.py#L233-L267 is our fallback logic which is why I think it is something else setting the backend to `'qt5agg'`. 
Here's are the exact steps to reproduce on Windows 10 and Windows 11.

## 1. Create a clean Conda environment and install deps

```
conda create -y -n test python=3.10
conda activate test
# make sure env is actually active and make sure pip comes from this env.
pip install matplotlib ipykernel PySide6  # all packages are pip installed.
```

## 2. In VS Code interactive, run the following cells step by step

```python
# %%
import matplotlib.pyplot as plt
import matplotlib as mpl

# %%
mpl.get_backend()  # returns 'module://matplotlib_inline.backend_inline'

# %%
plt.plot(range(10))  # Plots inline OK

# %%
mpl.get_backend()  # Still returns 'module://matplotlib_inline.backend_inline'

# %%
%matplotlib qt
plt.plot(range(10))  # ImportError: Failed to import any of the following Qt binding modules...

# %%
mpl.get_backend()  # returns 'Qt5Agg'

```
> > I'm curious to see where in code MPL decides to use the Qt5Agg backend by default.
> 
> It should not,
> 
> https://github.com/matplotlib/matplotlib/blob/b3bd929cf07ea35479fded8f739126ccc39edd6d/lib/matplotlib/pyplot.py#L233-L267
> 
> is our fallback logic which is why I think it is something else setting the backend to `'qt5agg'`.

I set a breakpoint on line 234 here, stepped through the code that raised the `ImportError`, and confirmed this branch was never hit.
Ok what the hell. The problem isn't with matplotlib, but IPython. I hardcore stepped through the code this time, and it turns out if you do **`%matplotlib qt`, `qt` always maps to `Qt5Agg`**. So if I only have Qt6 bindings, this would always break because IPython tells matplotlibto use `Qt5Agg` first, before matplotlib tries to actually import bindings.

https://github.com/ipython/ipython/blob/main/IPython/core/pylabtools.py#L26

https://github.com/ipython/ipython/blob/main/IPython/core/pylabtools.py#L301-L322
(I was about to post the same link, in fact just for posterity, I'll post the permalink rather than the main branch which can change: https://github.com/ipython/ipython/blob/396593e7ad8cab3a9c36fb0f3e26cbf79cff069c/IPython/core/pylabtools.py#L26)

Short term, you should be resolved by doing `%matplotlib qt6` instead... longer term, perhaps IPython should update that mapping.

Regardless, going to close as this is not a change we can do, as far as I can tell
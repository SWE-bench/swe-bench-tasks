I can confirm the issue on master (with Fedora 28, and Python 3.6 from conda).

Workflow to play with the issue:
1. a Python script `mwe.py` based on @Socob's snippet:
```python
import numpy as np
import matplotlib
import matplotlib.mlab as mlab
import matplotlib.pyplot as plt

mpl_version = matplotlib.__version__

delta = 0.025
X, Y = np.meshgrid(np.arange(-3, 3, delta), np.arange(-2, 2, delta))
Z1 = mlab.bivariate_normal(X, Y, 1.0, 1.0, 0.0, 0.0)
Z2 = mlab.bivariate_normal(X, Y, 1.5, 0.5, 1.0, 1.0)
Z = 10.0 * (Z2 - Z1)

fig, ax = plt.subplots(num="pgf_clabel_issue")
cs = ax.contour(X, Y, Z)
ax.clabel(cs, inline=True, fontsize=12)
ax.set_title('Matplotlib {}'.format(mpl_version))

#print("The backend is {}.".format(matplotlib.get_backend()))
fig.savefig("{0}_{1}.pgf".format(fig.get_label(), mpl_version))
```
2. a (La)TeX file `export_pgf.tex` to process the PGF file:
```latex
%% https://tex.stackexchange.com/questions/13349/tikz-to-non-pdf
\documentclass[convert={density=100,size=640x480,outext=.png}]{standalone}
\usepackage{pgf}

\begin{document}
    \input{target.pgf}
\end{document}
```
3. a Bash script `process.sh` that calls pdflatex to export the PGF file into PNG format:
```bash
PGFTARGET=$1  # the PGF file one wants to process and export
TMPTARGET="target.pgf"  # the file the TeX file will actually look for
cp $PGFTARGET $TMPTARGET

pdflatex --shell-escape export_pgf.tex
mv export_pgf.png "${PGFTARGET%.*}".png
#rm $TMPTARGET  # if one really wants to clean the temporary file
```
4. then one just has to run in CLI (leveraging the autocompletion to make things easier with the weird name of the PGF file ^^):
```bash
python mwe.py
./process.sh pgf_clabel_issue_<TAB>
```
Example of output file:
![pgf_clabel_issue_2 2 2 post1246 g6ec80eac6](https://user-images.githubusercontent.com/17270724/40994639-9c5446d8-68b1-11e8-8a08-33e5821b4ffc.png)

**Edit:** note to myself, a fully self-sufficient workflow, with *all* files is better...
So I think the issue is just that text clipping doesn't work for PGF:

```python
import matplotlib
import matplotlib.pyplot as plt

fig, ax = plt.subplots(num="pgf_clabel_issue")
ax.set_xlim([0, 1])
ax.set_ylim([0, 1])
ax.text(0.75, 0.5, 'Hi there this should clip, but bet it doesnot', clip_on=True)

fig.savefig("target.pgf")
```

[export_pgf.pdf](https://github.com/matplotlib/matplotlib/files/2174265/export_pgf.pdf)

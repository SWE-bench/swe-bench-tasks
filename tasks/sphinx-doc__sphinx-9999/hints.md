I don't think this is not a bug. It's not promised a term and description of the definition list are displayed as line-folded.

But I agree it's better to fold them as HTML does.
Great, thanks for the suggested pull request!
@marxin It may take some time before a solution is found because the natural #9988 approach breaks some numpy's LaTeX hack. As a work-around you may try to add to your project their hack
```
latex_elements = {
    'preamble': r'''
% In the parameters section, place a newline after the Parameters
% header
\usepackage{expdlist}
\let\latexdescription=\description
\def\description{\latexdescription{}{} \breaklabel}
% but expdlist old LaTeX package requires fixes:
% 1) remove extra space
\usepackage{etoolbox}
\makeatletter
\patchcmd\@item{{\@breaklabel} }{{\@breaklabel}}{}{}
\makeatother
% 2) fix bug in expdlist's way of breaking the line after long item label
\makeatletter
\def\breaklabel{%
    \def\@breaklabel{%
        \leavevmode\par
        % now a hack because Sphinx inserts \leavevmode after term node
        \def\leavevmode{\def\leavevmode{\unhbox\voidb@x}}%
    }%
}
\makeatother
''',
}
```
I am not completely happy with the resulting looks (see https://github.com/sphinx-doc/sphinx/pull/9988#issuecomment-997227939) but it may serve temporarily.
I don't think this is not a bug. It's not promised a term and description of the definition list are displayed as line-folded.

But I agree it's better to fold them as HTML does.
Great, thanks for the suggested pull request!
@marxin It may take some time before a solution is found because the natural #9988 approach breaks some numpy's LaTeX hack. As a work-around you may try to add to your project their hack
```
latex_elements = {
    'preamble': r'''
% In the parameters section, place a newline after the Parameters
% header
\usepackage{expdlist}
\let\latexdescription=\description
\def\description{\latexdescription{}{} \breaklabel}
% but expdlist old LaTeX package requires fixes:
% 1) remove extra space
\usepackage{etoolbox}
\makeatletter
\patchcmd\@item{{\@breaklabel} }{{\@breaklabel}}{}{}
\makeatother
% 2) fix bug in expdlist's way of breaking the line after long item label
\makeatletter
\def\breaklabel{%
    \def\@breaklabel{%
        \leavevmode\par
        % now a hack because Sphinx inserts \leavevmode after term node
        \def\leavevmode{\def\leavevmode{\unhbox\voidb@x}}%
    }%
}
\makeatother
''',
}
```
I am not completely happy with the resulting looks (see https://github.com/sphinx-doc/sphinx/pull/9988#issuecomment-997227939) but it may serve temporarily.

I don't think this is not a bug. It's not promised a term and description of the definition list are displayed as line-folded.

But I agree it's better to fold them as HTML does.
Great, thanks for the suggested pull request!
@marxin It may take some time before a solution is found because the natural #9988 approach breaks some numpy's LaTeX hack. As a work-around you may try to add to your project their hack
```
latex_elements = {
    'preamble': r'''
% In the parameters section, place a newline after the Parameters
% header
\usepackage{expdlist}
\let\latexdescription=\description
\def\description{\latexdescription{}{} \breaklabel}
% but expdlist old LaTeX package requires fixes:
% 1) remove extra space
\usepackage{etoolbox}
\makeatletter
\patchcmd\@item{{\@breaklabel} }{{\@breaklabel}}{}{}
\makeatother
% 2) fix bug in expdlist's way of breaking the line after long item label
\makeatletter
\def\breaklabel{%
    \def\@breaklabel{%
        \leavevmode\par
        % now a hack because Sphinx inserts \leavevmode after term node
        \def\leavevmode{\def\leavevmode{\unhbox\voidb@x}}%
    }%
}
\makeatother
''',
}
```
I am not completely happy with the resulting looks (see https://github.com/sphinx-doc/sphinx/pull/9988#issuecomment-997227939) but it may serve temporarily.
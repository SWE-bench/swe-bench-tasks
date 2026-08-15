For each we also need to make sure to check that the functions are defined in the same way. Sometimes one function will be normalized and the other won't, or the argument order may be different. 
It also makes sense both to test the text output and the function of the lambdified version (numerical results). See e.g. #17394 for an example of what the code may look like (note that there is a dictionary if it is just a matter of function names and the arguments are in the same direction etc), and what tests may look like, both using `print` and `lambdify`.
I would like to work on this issue, please guide me through this!
I would like to work on this issue
@mitanshu001 you can use my PR as a tutorial :) Plus I haven't had time to add tests yet, but I'll do it soon.
You should take a look at `pycode.py` and `SciPyPrinter`.
Can I work on this issue?
i would like to work on it . Though i am completely beginner i believe trying is better than doing nothing.
can somebody guide me ?  and what does module_format implies ? i see it a lot of time as self._module_format('scipy.sparse.coo_matrix')
You should look for the definition of the function https://github.com/sympy/sympy/blob/9fa2d4aa4683d24937f42d96f7fba4333ee6067a/sympy/printing/pycode.py#L122

It looks like it is related to a printer setting which controls whether it is printed as scipy.sparse.coo_matrix or just coo_matrix.
As I mentioned, I believe that [the PR I've done](https://github.com/sympy/sympy/pull/18185/files) is pretty much self-explanatory in terms of what you need to do.
<!--
/* Font Definitions */
@font-face
	{font-family:Mangal;
	panose-1:2 4 5 3 5 2 3 3 2 2;}
@font-face
	{font-family:"Cambria Math";
	panose-1:2 4 5 3 5 4 6 3 2 4;}
@font-face
	{font-family:Calibri;
	panose-1:2 15 5 2 2 2 4 3 2 4;}
@font-face
	{font-family:"Calibri Light";
	panose-1:2 15 3 2 2 2 4 3 2 4;}
/* Style Definitions */
p.MsoNormal, li.MsoNormal, div.MsoNormal
	{margin:0cm;
	margin-bottom:.0001pt;
	font-size:11.0pt;
	font-family:"Calibri",sans-serif;}
a:link, span.MsoHyperlink
	{mso-style-priority:99;
	color:blue;
	text-decoration:underline;}
.MsoChpDefault
	{mso-style-type:export-only;}
@page WordSection1
	{size:612.0pt 792.0pt;
	margin:72.0pt 72.0pt 72.0pt 72.0pt;}
div.WordSection1
	{page:WordSection1;}
-->Thank you for guiding me . shubham From: Michal GrňoSent: 07 March 2020 03:20 AMTo: sympy/sympyCc: SHUBHAM KHANTWAL; CommentSubject: Re: [sympy/sympy] Add more SciPy functions to code printer (#17396) As I mentioned, I believe that the PR I've done is pretty much self-explanatory in terms of what you need to do.—You are receiving this because you commented.Reply to this email directly, view it on GitHub, or unsubscribe. 
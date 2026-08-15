I would like to work on this, @moorepants could you explain how to start.

The issue is the printing I guess. 

This is also somewhat related to https://github.com/sympy/sympy/issues/6938. 

I updated the issue title. The function itself is distinct from `gamma`. The problem is that the printer is hardcoded to print gamma as Γ instead of γ. It should distinguish UndefinedFunctions and only apply the simple Symbol printing rules to them. 

Fine, then I'm working on it.

@asmeurer here, if we are defining gamma as a symbol it should print γ rather than Γ. This is the bug I guess, if I've got it right. 

I've been working on this issue but unable to locate where to make changes in the sympy code. @asmeurer 
please help.
The change should be made in sympy/printing/pretty/pretty.py. 
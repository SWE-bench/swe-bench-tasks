Does Jinja support this? I don't see how this could be a SQLFluff issue.
Your example does work on this website. I wonder if there's a Jinja runtime setting that affects whether this works.

http://jinja.quantprogramming.com/
It also works with `j2cli` on my local machine. Seems like this _has_ to be a Jinja runtime setting...

https://github.com/kolypto/j2cli
It was added in Jinja 2.8: https://jinja.palletsprojects.com/en/3.0.x/templates/#block-assignments

Not sure what version we pull in depending on our other dependencies?

I'm digging into this more. SQLFluff contains some additional code that attempts to detect undeclared Jinja variables and provide better error handling. The "issue" is being detected and reported by that code, not by Jinja itself. So we should be able to fix this. Need to do this carefully so we don't break error reporting for real errors. 
I think I have a fix. Just need to make the undefined variable check more sophisticated.
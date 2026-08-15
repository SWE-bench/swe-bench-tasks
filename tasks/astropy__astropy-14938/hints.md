@nstarman I am interested in working(actually already started working 😅 ) on this issue so can you assign it to me?
Hi @nstarman. I was working on this issue and with the context provided on the issue, I can't seem to figure out what changes needs to be done here, a bit more context would be helpful. 
PS: I found this repo 2 days back and am really new to it. Some help would be appreciated. 
Hi @yB1717, and welcome to Astropy! 
This PR is about registering another key to the registry at the bottom of
https://github.com/nstarman/astropy/blob/09f9a26f3484956d7446ebe0e3d560e03d501b02/astropy/cosmology/io/latex.py 
The actual change is just 1 line -- adding
```
readwrite_registry.register_writer("ascii.latex", Cosmology, write_latex)
```
The meat of this PR is really in the tests, making sure that "ascii.latex" is tested everywhere that "latex" is tested.
Ping me if you have any questions!

Thanks @nstarman for the help!
Sure I would ping you if I have any questions. 
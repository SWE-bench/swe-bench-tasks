In pmxbot/pmxbot@3adc54c, I've managed to pare down the project to a bare minimum reproducer. The issue only happens when `import-mode=importlib` and `doctest-modules` and one of the modules imports another module.

This issue may be related to (or same as) #10341.

I think you'll agree this is pretty basic behavior that should be supported.

I'm not even aware of a good workaround.
Hey @jaraco, thanks for the reproducer! 

I found the problem, will open a PR shortly.
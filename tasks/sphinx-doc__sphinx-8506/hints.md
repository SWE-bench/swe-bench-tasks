I disagree with 

> Sphinx ideally shouldn't change in ways that break the building of documentation that worked in older versions, because this makes it unworkably difficult to have documentation that builds with whatever the Linux distro's sphinx-build is.

The idea that things shouldn't change to avoid breaking is incredibly toxic developer culture. This is what pinned versions are for, additionally, you can have your project specify a minimum and maximum sphinx as a requirement.
I agree that there's some philosophical differences at play here. Our project wants to be able to build on a fairly wide range of supported and shipping distributions (we go for "the versions of major distros still supported by the distro vendor", roughly), and we follow the usual/traditional C project/Linux distro approach of "build with the versions of libraries, dependencies and tools shipped by the build platform" generally. At the moment that means we need our docs to build with Sphinx versions ranging from 1.6 through to 3.2, and the concept of a "pinned version" just doesn't exist in this ecosystem. Being able to build with the distro version of Sphinx is made much more awkward if the documentation markup language is not a well specified and stable target for documentation authors to aim at.

Incidentally, the current documentation of the option:: directive in https://www.sphinx-doc.org/en/master/usage/restructuredtext/domains.html?highlight=option#directive-option says nothing about this requirement for -, --, / or +.

For the moment I've dealt with this by rewriting the fragment of documentation to avoid the option directive. I don't want to get into an argument if the Sphinx project doesn't feel that strong backward-compatibility guarantees are a project goal, so I thought I'd just write up my suggestions/hopes for sphinx-build more generally for you to consider (or reject!) and leave it at that:

* Where directives/markup have a required syntax for their arguments, it would be useful if the documentation clearly and precisely described the syntax. That allows documentation authors to know whether they're using something as intended.
* Where possible, the initial implementation should start with tightly parsing that syntax and diagnosing errors. It's much easier to loosen restrictions or use a previously forbidden syntax for a new purpose if older implementations just rejected it rather than if they accepted it and did something different because they didn't parse it very strictly.
* Where major changes are necessary, a reasonable length period of deprecation and parallel availability of old and new syntax helps to ease transitions.

and on a more general note I would appreciate it if the project considered the needs of external non-Python projects that have adopted Sphinx as a documentation system but which don't necessarily have the same control over tooling versions that Python-ecosystem projects might. (The Linux kernel is another good example here.)

> Where major changes are necessary, a reasonable length period of deprecation and parallel availability of old and new syntax helps to ease transitions.

Major versions are done via semver, where Sphinx 2 is a major breaking change over Sphinx 1, and Sphinx 3 breaks changes over Sphinx 2. What other things could be done? The concept of deprecation isn't as common in Python communities due to the popularity of fixed versions or locking to a major version. IE ``pip install sphinx==3`` which installs the latest major sphinx version of 3.
This change was added at https://github.com/sphinx-doc/sphinx/pull/7770. It is not an expected change. It means this is a mere bug.
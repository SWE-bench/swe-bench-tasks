I created a PR ​https://github.com/django/django/pull/7578
In e690eb40: Refs #27505 -- Made Paginator's exception messsages translatable.
Strings are now marked for translation. Easing customization of error messages to be done separately.
Does this still need work?
Replying to Shivan Sivakumaran: Does this still need work? Yes, see comment: ... Easing customization of error messages to be done separately.
Hi, I'm a new contributor and I'd love to give it a try
Replying to Pedro Magno Müller: Hi, I'm a new contributor and I'd love to give it a try hi are you still working on it or may i take the issue?
don't we have a workaround for that like directly import "PageNotAnInteger" and "EmptyPage" Exceptions directly and use them in our logic isn't it , a way to customization .?
Replying to Aman Pandey: Replying to Pedro Magno Müller: Hi, I'm a new contributor and I'd love to give it a try hi are you still working on it or may i take the issue? Hello, Can i take this up?
surReplying to Uzair Ali: Replying to Aman Pandey: Replying to Pedro Magno Müller: Hi, I'm a new contributor and I'd love to give it a try hi are you still working on it or may i take the issue? Hello, Can i take this up? yea sure but can we work together like ?
I am unsure if this customisation is needed anymore as currently, all usages of Paginator.validate_number will have a try/except block to catch the ValueError exception and set it as 1.
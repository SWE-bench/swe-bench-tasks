​PR
Updated PR to address feedback. Thanks.
In b3cffde5: Fixed #29324 -- Made Settings raise ImproperlyConfigured if SECRET_KEY is accessed and not set.
This causes a regression when using settings.configure(). UserSettingsHolder does not handle the missing SECRET_KEY attribute, and raises an AttributeError instead of ImproperlyConfigured. (Discovered by bukensik in #django)
​PR for the regression.
In 5cc81cd9: Reverted "Fixed #29324 -- Made Settings raise ImproperlyConfigured if SECRET_KEY is accessed and not set." This reverts commit b3cffde5559c4fa97625512d7ec41a674be26076 due to a regression and performance concerns.
In 483f5d6c: [2.1.x] Reverted "Fixed #29324 -- Made Settings raise ImproperlyConfigured if SECRET_KEY is accessed and not set." This reverts commit b3cffde5559c4fa97625512d7ec41a674be26076 due to a regression and performance concerns. Backport of 5cc81cd9eb69f5f7a711412c02039b435c393135 from master
I reverted the original patch for now as Claude expressed some concerns, "I'm not sure to like the additional test for every setting access, for a corner-case use case. I think we should consider reverting the initial patch instead." I'll leave the ticket open for Jon to provide an alternative patch or to close the ticket as wontfix.
​PR
After researching the code necessary to handle the edge cases, I don't think the complexity is worth it to include in Django. I'll stick with my local project workaround instead.
Reopening after recent ML discussion: ​https://groups.google.com/g/django-developers/c/CIPgeTetYpk
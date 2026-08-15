We've introduced django-admin because commands don't usually have "language extensions". We're keeping django-admin.py for backwards-compatibility. There's little benefit to remove django-admin.py and it would be very disruptive. Maybe we'll do to at some point, but not soon.
We should wait until support for Django 1.6 ends to remove django-admin.py. Otherwise, it will become complicated to write version-independent test scripts (think tox.ini).
If we do remove it, we should officially deprecate it first, right?
Yes, the fast track would be to deprecate it in Django 1.8 and remove it in Django 2.0. However, there's almost no downside to keeping it for a few more years, and it will avoid making many tutorials obsolete (for example).
​PR
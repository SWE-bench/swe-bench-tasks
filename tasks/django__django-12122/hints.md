Milestone post-1.0 deleted
Same problem here. Any solution?
corrected rfc2822 implementation and added tests
The attached patch makes the 'r' flag returns an RFC 2822 formatted date string even when LANGUAGE_CODE is set to something other than English. Added regression tests to reflect this issue. There will be a simpler solution once Python implements a datetime-RFC 2822 export feature ( ​http://bugs.python.org/issue665194 ).
Tests in patch need updating -- that file has been converted to unit tests.
updated tests to unit tests and fixed an issue with tzinfo
updated tests to unit tests and fixed an issue with tzinfo
The patch now includes new tests. An existing unit test was modified to adhere to a common RFC 2822 standard. This patch generates the date string using Python's email.utils.formatdate (available in py2.4). The above Python issue is still open, but its solution will allow for a much more straightforward solution. It looks to be slated for Python 2.7: ​http://bugs.python.org/issue665194
restored system settings.LANGUAGE_CODE after monkeying around
Should this handle timezone infromation?, if the answer is no then this patch is on the right track, if the answer is yes then maybe we should handle things manually (and move the code to a helper function) instead of using email.utils (e.g. like we are douiing in the feed geenrator: ​http://code.djangoproject.com/browser/django/trunk/django/utils/feedgenerator.py?rev=15505#L39)
rfc2822.3.diff fails to apply cleanly on to trunk
Change UI/UX from NULL to False.
this is still a problem
guys, this is really annoying... a workaround is to import the rfc2822_date from django.utils.feedgenerator and just register it as an own filter.
Pull request available at ​https://github.com/django/django/pull/12122
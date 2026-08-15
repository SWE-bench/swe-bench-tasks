Seems like a good improvement to me. A patch would be great.
Fix.
Any comments on this patch? Is it OK?
The patch doesn't apply any more (the relevant code is now in django/core/management/base.py). I've adapted the patch, but I'm not sure how this should interact with the _make_writeable call. I'll upload the updated patch anyway, just in case.
Updated patch, against revision 6281.
Patch needs to be updated again.
Confirmed issue still exists in r16741. This patch applies cleanly and fixes the issue.
I uploaded & updated the pull request. ​https://github.com/django/django/pull/2061 would be great if somebody will making suggestions.
Comment added on the pull request.
Browsing some ancient tickets, wondering if this ticket can perhaps be closed as obsolete? If not - what is still missing? Ticket isn't very clear on what the issue is and how to reproduce is, but a lot has changed on permission handling between the time of the ticket and #17042, #26494, #27628.
(de-assigning as not touched in 8 years)
Hey Adam — thanks for looking! Seems like the behaviour is unchanged (to 4.0b1): % mkdir issue4282 % cd issue4282 issue4282 % umask 077 issue4282 % touch foo issue4282 % ls -l foo -rw------- 1 carlton staff 0 Nov 16 10:06 foo issue4282 % django-admin startproject mysite issue4282 % ls -l mysite/mysite/settings.py -rw-r--r-- 1 carlton staff 3221 Nov 16 10:06 mysite/mysite/settings.py issue4282 % django-admin --version 4.0b1 Expected behaviour is that the created files have the restricted permissions, I think. The original patch didn't look too complex… 🤔 (We do similar in ​storage.py — I didn't look into Claude's comments on the PR there.) It may be that if we're not going to fix this, we can mark it wontfix. (Is this something Django needs to handle that a find ... | xargs chmod wouldn't be more appropriate for?)
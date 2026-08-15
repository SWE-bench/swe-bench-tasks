Yes, that code is fragile.
I reproduced it. I'm working now on fix.
sample project, which show how patch works now
I sended pull request. ​https://github.com/django/django/pull/2584 The problem is that methods without the 'item' argument (only with self) should be static now: @staticmethod def item_description(self): return force_text(item) But the decorators work now (sample project is in attachments)
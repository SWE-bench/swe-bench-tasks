app = settings.INSTALLED_APPS[0] is actually useless in the example.
Can't we just add a label attribute to the ModelAdmin class? ModelAdmin classes with same label would group, possibly also position attribute.
Im just thinking that the application grouping might not have much to do with how an administrator uses the admin tool.
What do you think of something like an optional layout?: admin.site.layout = ( (_("don't touch this stuff"), { 'models': ('', 'django.contrib.sites.models.Site', ) }), (_('users & groups'), { 'models': ('django.contrib.auth.models', 'User', 'Group' ) }), (_('pages & news'), { 'models': ('', 'example_project.pages.models.Page', 'example_project.news.models.News', ) }), ) Also adding a description attribute to ModelAdmin. You can see and read further on this idea and look at the implementation in my project ​sorl-curator
Milestone post-1.0 deleted
A somewhat related point - if you have two applications with the same basename in the one project, the admin application displays them as if they were merged into a single application with that name. E.g. If 'foo.bar.myapp' and 'spam.eggs.myapp' are both in the INSTALLED_APPS list, and both have an admin.py; then admin displays them both as a single merged 'myapp' application.
#11895 proposed a similar idea, and provided a patch (which could also be implemented using subclassing).
Added CC.
This is #3591 — also known as the 'app-loading' branch.
Mmm, in fact this was specifically split from app-loading. Sorry.
Hi, I implemented apps ordering via "position" attribute in AppConfig class class TestConfig(AppConfig): name = 'test' verbose_name = 'Test App' position = 0 Apps orders by it's "position" and then by "verbose_name", no backwards incompatible, if position not set just ordering by name. If it's actual I can do pull request.
To move things a little bit forward I have prepared a pull request based on this comment https://code.djangoproject.com/ticket/25671#comment:11 ​https://github.com/django/django/pull/15483
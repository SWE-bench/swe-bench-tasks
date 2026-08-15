Hi Nicolas. I'm going to Accept this: it seems reasonable. …in cases it would disable colors by default (typically, when the output is piped to another command, as documented). Can I ask, where is this documented? I cannot seem to find it. Thanks.
Thanks Carlton! It is documented in ​https://docs.djangoproject.com/en/2.0/ref/django-admin/#syntax-coloring: The django-admin / manage.py commands will use pretty color-coded output if your terminal supports ANSI-colored output. It won’t use the color codes if you’re piping the command’s output to another program.
Thanks Nicolas. I just found that. (I must have been blind: I even looked in that exact location... sigh :-)
I unfortunately can't find time in the short term to work on the implementation...
PR​https://github.com/django/django/pull/10213
This looks good to me. (I had a couple of tiny comment which I assume will be addressed, so progressing.) Thanks Hasan.
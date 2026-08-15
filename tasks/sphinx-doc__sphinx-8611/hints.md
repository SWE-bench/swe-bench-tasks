AFAIK, Sphinx does not emit such a warning. I guess the warning came from 3rd party extensions.
It seems your conf.py emits the warning.
https://github.com/altendky/qtrio/blob/bf3bcc41e8d63216153bbc42709550429bcf38ff/docs/source/conf.py#L99-L102
Thanks for taking a look and for pointing out that my own code is generating the warning.  Obviously I should have identified this myself and included it in the original report.

That said, it isn't clear to me yet why this should have changed with v3.4.0.  I'm trying to walk through with a debugger to understand this better.  There are many other inherited attributes that this does not happen for and while I don't yet know what about it would be significant, `staticMetaObject` is the only attribute listed for `QObject` as 'static' (C++) and which is not a method.

https://doc.qt.io/qt-5/qobject.html#static-public-members

I'll let you know what I find.
A bisect points at https://github.com/sphinx-doc/sphinx/commit/3638a9e4d15526272f3ba3f735a20c30d98cea14 and the comments at https://github.com/sphinx-doc/sphinx/commit/3638a9e4d15526272f3ba3f735a20c30d98cea14#r45371488 sound applicable to my case.  You said the change was not intended but I don't see a link to any other issues being reported or PRs.  The symptom (my warning) is still present at https://github.com/sphinx-doc/sphinx/commit/f18e988dea7111a2b48592a989448037778e8217.

Do you expect to undo this changed behavior?  I understand that other tasks, for Sphinx or just life in general, likely take priority but I want to understand if this is viewed as a bug to be fixed or if I should adapt to the new behavior.
About https://github.com/sphinx-doc/sphinx/commit/3638a9e4d15526272f3ba3f735a20c30d98cea14, I fixed it in https://github.com/sphinx-doc/sphinx/pull/8581, and it was released as v3.4.1 now. If my understanding is correct, it has been already fixed. But, it seems I need to retake a look (and deeply).
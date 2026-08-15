fix
Fix is quite simple but a regression test can be tricky.
Hi felixxm, I also just made a ticket #30545 with more details. Working through all the logical combinations I think both the old code and new code have other bugs and I've posted a suggested fix there.
Updated description with detail from #30545
I think there is a potential simplification of my solution: if get_field raises the FieldDoesNotExist exception then I suspect getattr(obj.model, item) might always fail too (so that test could be omitted and go straight to returning the E108 error), but I'm not sure because the inner workings of get_field are rather complicated.
My proposed changes as pull request: ​PR
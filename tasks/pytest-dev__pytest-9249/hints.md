The test ids are not invalid, keyword expressions are simply not able to express slashes

It's not clear to me if that should be added 
I am not sure either, but I wanted to underline the issue, hoping that we can find a way to improve the UX. The idea is what what we display should also be easily used to run a test or to find the test within the source code.

I was contemplating the idea of using indexes instead of test id.
Actual test ids can be passed as such, no need for keyword expressions 
updated the title to more accurately reflect that the ids aren't invalid, they just can't be selected using `-k`
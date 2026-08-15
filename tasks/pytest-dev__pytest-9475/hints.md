@okken would you like to make the deselected a optional parameter to ensure this is caught

i believe we have to make certain new features "explicit optionals" instead of implied optionals

this one is a easy miss, i'm pretty sure at least 3 of us missed this when glancing at the pr before, and we would miss a issue like that again, as making it visible would require a explicit and elaborate design of the matcher to begin with

this type of regression is pretty much only caught by overly detailed test suites, so given the circumstances we rather ought to focus on making it inexpensive to react on them

lets try to make it a actual optional parameter before 7.0 but not get hung up on it in case it turns out tricky
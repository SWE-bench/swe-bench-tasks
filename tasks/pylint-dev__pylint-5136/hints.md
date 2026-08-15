I hate the current design, so I like this proposition ! But merging pylinter and MessageHandlerMixin could mean having to extract an independant MessageHandler class and possibly others because the pylinter class already is humungous. 
I wonder how many methods will remain for the independent class. A quick look shows that most current methods use attributes/methods from most classes. 

We could separate those into different method that call each other but that might make the code more confusing, for example with `add_message`. 
I can take a look at this after the work on `LinterStats` has been approved and merged. I'll assign myself.

Input from others is still appreciated!
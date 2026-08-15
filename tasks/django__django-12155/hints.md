Confirmed the patch fixes the issue, although it crashes for some tests with ValueError: min() arg is an empty sequence.
We should probably just switch to inspect.cleandoc as ​it implements the algorithm ​defined in PEP257.
Replying to Tim Graham: Confirmed the patch fixes the issue, although it crashes for some tests with ValueError: min() arg is an empty sequence. Yes, I also found it yesterday. The simple solution is: indent = min((len(line) - len(line.lstrip()) for line in lines[1:] if line.lstrip()), default=0) The default argument was added in Python 3.4, so it is safe to use in Django.
Hello folks: Can I PR?
I couldn't reproduce it on: Python=3.7 django=master docutils=0.15.2 @Manlio Perillo, Could you please help me? I am wrong?
@Manlio Perillo, I couldn't reproduce this bug. Could you please provide more information about this bug? Python version, docutils version? It would be good to have a model definition or test case. Thanks.
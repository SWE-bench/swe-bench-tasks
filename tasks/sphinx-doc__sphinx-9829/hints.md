I'm not good at loading JS. Could you let me know the impact of changing `async` to `defer`? Are there any incompatible change for users? If not, we can change the loading option for MathJax to `defer` in the next version.
I don't think it's an incompatible change.  For MDN:

> - If the async attribute is present, then the script will be executed asynchronously as soon as it downloads.
> - If the async attribute is absent but the defer attribute is present, then the script is executed when the page has finished parsing.

So changing `async` to `defer` just rules out certain behaviors (the script starts executing before the whole page is parsed), it shouldn't add any new ones.

I found an explanation for this topic:

>Note that here we use the defer attribute on both scripts so that they will execute in order, but still not block the rest of the page while the files are being downloaded to the browser. If the async attribute were used, there is no guarantee that the configuration would run first, and so you could get instances where MathJax doesn’t get properly configured, and they would seem to occur randomly.
>https://docs.mathjax.org/en/latest/web/configuration.html#using-a-local-file-for-configuration

I believe using defer option instead is a good alternative.
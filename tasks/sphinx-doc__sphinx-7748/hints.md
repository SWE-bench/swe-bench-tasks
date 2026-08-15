Why don't overloaded methods have correct signature? I'd like to know why do you want to use `autodoc_docstring_signature`. I think it is workaround for special case.
is there any workaround for this?
@3nids Could you let me know your problem in detail please. I still don't understand what is real problem of this issue. Is there any minimal reproducible example?
We use Sphinx to document Python bindings of a Qt C++ API.
We have overloaded methods in the API:

for instance, the method `getFeatures` has 4 overloaded signatures.
The generation documentation appends the 4 signatures with the 4 docstrings.
This produces this output in the docs:

![image](https://user-images.githubusercontent.com/127259/67165602-6446b200-f387-11e9-9159-260f9a8ab1fc.png)

Thank you for explanation. I just understand what happened. But Sphinx does not support multiple signatures for python objects unfortunately. So there are no workarounds AFAIK. I'll consider how to realize this feature later.
Would it be possible to sponsor such feature? 
Now Sphinx does not join any sponsorship programs. So no way to pay a prize to this feature.

off topic: Personally, I just started GitHub sponsors program in this week. So sponsors are always welcome. But I'd not like to change order by sponsor requests...
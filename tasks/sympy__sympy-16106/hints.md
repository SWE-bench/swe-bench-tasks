Now it returns
```
'<indexed><indexedbase><ci>a</ci></indexedbase><ci>b</ci></indexed>'
```
for content printer and 
```
'<mrow><mi>indexed</mi><mfenced><mrow><mi>indexedbase</mi><mfenced><mi>a</mi></mfenced></mrow><mi>b</mi></mfenced></mrow>'
```
for presentation printer.

Probably not correct as it seems like it falls back to the printer for `Basic`.

Hence, a method `_print_IndexedBase` is required. Could be good to look at the LaTeX version to see how subscripts etc are handled.
Hi, can I take up this issue if it still needs fixing?
@pragyanmehrotra It is still needed so please go ahead!
@oscargus Sure I'll start working on it right ahead! However, Idk what exactly needs to be done so if you could point out how the output should look like and do I have to implement a new function or edit a current function it'd be a great help, Thanks.
```
from sympy import IndexedBase
a, b = symbols('a b')
IndexedBase(a)[b]
```
which renders as
![image](https://user-images.githubusercontent.com/8114497/53299790-abec5c80-383f-11e9-82c4-6dd3424f37a7.png)

Meaning that the presentation MathML output should be something like
`<msub><mi>a<mi><mi>b<mi></msub>`

Have a look at #16036 for some good resources.

Basically you need to do something like:
```
m = self.dom.createElement('msub')
m.appendChild(self._print(Whatever holds a))
m.appendChild(self._print(Whatever holds b))
```
in a function called `_print_IndexedBase`.
You can control print order as described [here](https://stackoverflow.com/a/58541713/1089161).
The default order should not break the multiline bracket of pretty print. Please see the output in constant width mode or paste it in a text editor. The second output is fine while the right bracket is broken in the other two.
I can verify that this seems to be an issue specific to pretty print. The Latex renderer outputs what you want. This should be fixable. Here is an image of the output for your vectors from the latex rendered in Jupyter.
![image](https://user-images.githubusercontent.com/1231317/153658279-1cf4d387-2101-4cb3-b182-131ed3cbe1b8.png)

Admittedly the small outer parenthesis are not stylistically great, but the ordering is what you expect.
The LaTeX printer ought to be using \left and \right for parentheses. 
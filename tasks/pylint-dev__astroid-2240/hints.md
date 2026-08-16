Should the definition be changed as well? It states `args.arguments` returns required arguments, and AFAIK in the example none are required (I can call `a` without supplying any arguments).

I tried running the following:

```
>>> node = extract_node("""def a(kiwi, apple, *args, b=None, c=None, **kwargs): ...""")
>>> node.args.arguments
[<AssignName.kiwi l.1 at 0x7f5c55986b90>, <AssignName.apple l.1 at 0x7f5c55985a50>]
```

And it seems correct to me :thinking: 
https://github.com/pylint-dev/astroid/blob/fef38f2dd474b0dacd1dda3f15abbf61eb0e9a71/astroid/nodes/node_classes.py#L685-L688

The docstring seems to be correct?
Depends on how you parse the language. "positional and keyword" could describe the argument `kiwi` and exclude keyword-only arguments.

Essentially, the crux of this is whether we should
- leave the function as is, and audit everywhere that uses it (given that we keep finding bugs)
- change the function

@crazybolillo have you happened to sample the places that use this function to be able to offer a view on that? I'd be eager to hear it!
I think I got confused about the documentation :sob:. I was reading the docstring for `args` (`node.args.args` in the example):

https://github.com/pylint-dev/astroid/blob/d4f4452fe089f600bf9144ffdcd8e698816df3c2/astroid/nodes/node_classes.py#L554-L555

 but we are dealing with `arguments` (`node.args.arguments`). I will review the code further to see if I can come up with something


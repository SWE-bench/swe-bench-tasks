I think the former proposal is cool. It's good for me. +1 for adding the option. At this moment, some libraries and applications must support old intepreters that does not supporting type union operator. So it's useful until the deprecation of them.

On the other hand, I'm not sure another proposal is really good. The converted code is not valid in Python. I agree "Literal" text is not meaningless in the document. But I'm afraid the invalid code confuses readers. Could you show any rendered example? I'd like to see a real example.
Here is an example of the `Literal` transformation:

https://google.github.io/tensorstore/python/api/tensorstore.TensorStore.read.html#p-order

The `order` parameter is annotated with the type `Optional[Literal['C','F']]`.

While it is invalid Python syntax, it is unambiguous, except in the case of `Literal[T]`, where `T` is itself a type.  But in that case you could instead use the more customary form `Type[T]` rather than `Literal[T]`.
Thank you for the pointer. Indeed, it's not so bad. Personally, I prefer using `Literal`. But it would be a candidate of the format of API references. +0 to adding an option for it.

@shimizukawa Do you have any comment for this?
> I think the former proposal is cool. It's good for me. +1 for adding the option. 

+1 from me too.

>`order: 'C' | 'F' = 'C'` 

+0. 
If the official Python documentation generated documentation using this feature, they would use `Literal['C','F']`. However, it is understandable that someone would want to choose ease of communication over accuracy. It would be good if document writer could choose whether to output `Literal['C','F']` or `'C' | 'F'`.
@jbms #11072 does this for Optional and Union; though avoids changing Literal as no "short" display mechanism has been adopted for upstream Python use. I'd be interested in your view here of what (if anything) we should do re literals -- add an option for the short display format you propose, do nothing, etc.

Thanks!

A
Thanks for adding the optional/union change.  For literal I think it would make sense to add a config option that defaults to false, as we've done in sphinx-immaterial:

https://jbms.github.io/sphinx-immaterial/apidoc/python/index.html#confval-python_transform_type_annotations_concise_literal

Note that the concise literal formatting is unambiguous when used in documentation, because we never represent type names as string literals.  However, in Python source code, a real string literal would be ambiguous with specifying a type name as a string literal.

More generally, it would also be nice if there were a mechanism for extensions to manipulate the ast of type annotations before they are formatted, either a sphinx event or something else, since it is somewhat difficult to accomplish that with monkey patching.
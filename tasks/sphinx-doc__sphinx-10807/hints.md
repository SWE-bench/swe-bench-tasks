I will try to make this enhancement, but am hoping that someone can point me to the right place in the code.
What is the target date for the 3.0.0 milestone?
3.0 will be released in next spring.
@Phillip-M-Feldman are you still planning to work on this? @tk0miya you added this issue to the 3.0.0 milestone: are you going to implement it?
I did spend some time on this, but wasn't able to figure it out.  I will
likely try again within the next few weeks.

On Mon, Dec 9, 2019 at 4:52 AM Timothée Mazzucotelli <
notifications@github.com> wrote:

> @Phillip-M-Feldman <https://github.com/Phillip-M-Feldman> are you still
> planning to work on this? Why are you asking about the 3.0.0 milestone? Has
> it been implemented already?
>
> —
> You are receiving this because you were mentioned.
> Reply to this email directly, view it on GitHub
> <https://github.com/sphinx-doc/sphinx/issues/6316?email_source=notifications&email_token=AAIEDRDSU4ALMXRU2RFWLG3QXY5RNA5CNFSM4HHS4DW2YY3PNVWWK3TUL52HS4DFVREXG43VMVBW63LNMVXHJKTDN5WW2ZLOORPWSZGOEGJCBGY#issuecomment-563224731>,
> or unsubscribe
> <https://github.com/notifications/unsubscribe-auth/AAIEDRFBP5Q3OFA54VATFXDQXY5RNANCNFSM4HHS4DWQ>
> .
>

I'm currently writing [a plugin for mkdocs](https://github.com/pawamoy/mkdocstrings) with this functionality anyway :slightly_smiling_face: 
No, I don't have time for developing 3.0. At present, I'm doing my best to 2.x release.
What is the relationship (if any) between mkdocs and Sphinx?

Also: I have some time to work this issue, but still need pointers re. where to look in the code.

P.S. I'm surprised that this functionality wasn't built into Sphinx from the start.
Sphinx and MkDocs both are static site generators if I may say? MkDocs is language agnostic and uses Markdown natively. Other than that there's no relation between the two.
Thank you!  I think that I will stick with Sphinx, despite some severe
limitations, because of its Python-centric approach.

On Mon, Aug 17, 2020 at 12:51 PM Timothée Mazzucotelli <
notifications@github.com> wrote:

> Sphinx ans MkDocs both are static site generators if I may say? MkDocs is
> language agnostic and uses Markdown natively. Other than that there's no
> relation between the two.
>
> —
> You are receiving this because you were mentioned.
> Reply to this email directly, view it on GitHub
> <https://github.com/sphinx-doc/sphinx/issues/6316#issuecomment-675078507>,
> or unsubscribe
> <https://github.com/notifications/unsubscribe-auth/AAIEDRHHLSLADXSYYIANOB3SBGC4PANCNFSM4HHS4DWQ>
> .
>

I'm voting up for this feature. It seems essential to me.
Hi, thanks for the great idea to improve Sphinx.

It’s already more than 2 years. Any new progress on this topic? Is there a release plan? Will it be in 5.0? 

I may contribute if it is welcome.

Btw, a current workaround might be using the extension sphinx-autoapi rather than the traditional autodoc to add object domain into the toctree.
Alrighty. I looked into this and the relevant bit of `toc` generation code in Sphinx is here:

https://github.com/sphinx-doc/sphinx/blob/58847682ccd91762608f3a5a023b244675e8470b/sphinx/environment/collectors/toctree.py#L79-L130

For implementing this, I can see two options:

- Inject the relevant anchors into the `env.tocs` object using logic similar to what sphinx-autoapi does:

   https://github.com/readthedocs/sphinx-autoapi/blob/19d217e177d76b40318a30a7cd25195d09530551/autoapi/toctree.py#L123

- Add discoverability of such anchors into the existing logic (linked above).

Either way, I think it is most sensible to have this be done behind an opt-in configuration option. I'm fairly certain that if someone steps up to implement either option[^1], such a PR would be welcome; subject to the regular code review stuff. :)

[^1]: I have a preference for the first one; it would keep the "new" behaviour as autodoc-specific and it's also clearer IMO!
@pradyunsg 

If we inject the relevant anchors, we might meet with the same issue that `sphinx-autoapi` has.  
I wonder if there is any convenient solution to insert the anchors into the expected place.

An example (wrong order):  
https://github.com/readthedocs/sphinx-autoapi/issues/308  
It is first proposed by (wrong structure):  
https://github.com/readthedocs/sphinx-autoapi/issues/283  

It seems the author of `sphinx-autoapi` previously worked on this (claimed in sphinx-autoapi/issues/283), which is also mentioned in this issue.  
https://github.com/AWhetter/sphinx/commit/175b14203798ddcc76a09882f54156ea31c43c9d

My personal thought is to add discoverability of such anchors into the existing logic, so that the order is correct all the time.
As indicated in the sphinx-autoapi issue I think this is a valuable feature, but it would need to be done carefully, and some major design descisions must be made:

- How are nested directives handled? Should they be in the toc or not? E.g.,
  ```rst
  .. py:class:: A

     .. py:method:: f
  ```
  is that TOC-wise equivalent to the following?
  ```rst
  Heading for A
  =============

  Heading for f
  -------------
  ```
- How does it interact with normal headings? E.g,
  ```rst
  Heading
  =======
  
  Sub-heading
  -----------
  
  .. py:class:: A
  ```
  does that mean
  ```
  * Heading
    * Sub-heading
      * A
  ```
  or
  ```
  * Heading
    * Sub-heading
    * A
  ```
  or
  ```
  * Heading
    * Sub-heading
  * A
  ```
  ? All three are reasonable in different cases. Perhaps the user must attach a "level" option on the directives that goes into the TOC.
- How can a domain opt into this functionality? Domains are in principle external to the core of Sphinx so an API must be developed.
- How can a user opt in/out per directive? and/or per directive type (e.g., all classes, but not functions)? and/or per domain?
@jakobandersen I agree that it's a design issue. We may need to get maintainer's decision on this.
Not a maintainer and... my thoughts on the two easy questions:

> How are nested directives handled? Should they be in the toc or not? E.g.,
> ```
> .. py:class:: A
> 
>    .. py:method:: f
> ```
> is that TOC-wise equivalent to the following?
> ```
> Heading for A
> =============
> 
> Heading for f
> -------------
> ```


Yes.

> ```
> Heading
> =======
> 
> Sub-heading
> -----------
> 
> .. py:class:: A
> ```
> does that mean
> ```
> * Heading
>   * Sub-heading
>     * A
> ```

Yes.

@pradyunsg 

If that's the design, how to express the other 2 cases:

```
* Heading
  * Sub-heading
  * A
```
```
* Heading
  * Sub-heading
* A
```
In mkdocstrings we indeed have an option to change the heading level. Each top-level autodoc instruction by default renders a level 2 heading. There's no nesting in the markup itself, so autodoc instructions are always "top-level". It means

```
# Heading

## Sub-heading

::: identifier
```

...is equivalent to headings with levels 1, 2 and 2 (the default) respectively, not 1, 2 and 3.

Users can change the default globally, but also per autodoc instruction. The headings levels in docstrings themselves are also automatically shifted based on their parent level, so if you have a level 1 heading in the docstring of an object rendered with an initial level 4, this level 1 heading becomes a level 5.
> If that's the design, how to express the other 2 cases:

Why do you want to?

I don't think there's much value in trying to design to accommodate for theoretical edge cases. If you have a specific example, that would be great.

I'm thinking of https://packaging.pypa.io/en/latest/requirements.html, where it is clear that nesting underneath is the right thing to do.

> In mkdocstrings we indeed have an option to change the heading level.

This seems like it could be reasonable! An optional option in the autodoc directive to specify the depth could achieve this. 
@pradyunsg, I basically agree with https://github.com/sphinx-doc/sphinx/issues/6316#issuecomment-998301185 as a good default behaviour, and I don't think we need to implement functionality for the rest unless anyone requests it. However, we should just be reasonably sure that such a modification can actually be done later.

> In mkdocstrings we indeed have an option to change the heading level. Each top-level autodoc instruction by default renders a level 2 heading. There's no nesting in the markup itself, so autodoc instructions are always "top-level".

> Users can change the default globally, but also per autodoc instruction. The headings levels in docstrings themselves are also automatically shifted based on their parent level, so if you have a level 1 heading in the docstring of an object rendered with an initial level 4, this level 1 heading becomes a level 5.

So if I understand that correctly the levels are sort of absolute, but relative to their insertion point? So you may end up with a level 1 heading with a level 5 heading inside, without the intermediary levels?
In any case: in Sphinx I think they should simply be relative, so a top-level declaration should be nested below the latest heading. That is,
```rst
H1
##

.. py:class:: A1

H2
==

.. py:class:: A2

H3
--

.. py:class:: A3
```
would produce
```
- H1
  - A1
  - H2
    - A2
    - H3
      - A3
```
Then my second question from https://github.com/sphinx-doc/sphinx/issues/6316#issuecomment-997885030 can be rephrased as whether to make declarations either a nested section, a sibling section, or a sibling section of the parent section.
In the future we could then imagine adding a directive option a la ``:heading:`` which defaults to ``+1`` and the two other cases could be expressed by ``:heading: 0`` and ``:heading: -1``, or something similar.
Giving ``:heading: None`` could then be used to disable TOC insertion.
@pradyunsg 

> Why do you want to?
> 
> I don't think there's much value in trying to design to accommodate for theoretical edge cases. If you have a specific example, that would be great.

Hope my doc could be an example: https://ain-soph.github.io/alpsplot/figure.html  

```
ALPSPLOT.FIGURE
============

Linestyles
-----------

Markers
----------

.. py:class:: Figure

```

where `Linestyles, Markers and Figure` are siblings.
>In the future we could then imagine adding a directive option a la :heading: which defaults to +1 and the two other cases could be expressed by :heading: 0 and :heading: -1, or something similar.

I prefer not to add a style option to the directives. I believe separating structures from styles is a better idea. So the configuration should be separated from "object descriptions". So I'd not like to control (the depth of) the conversion rule manually.
> > In the future we could then imagine adding a directive option a la :heading: which defaults to +1 and the two other cases could be expressed by :heading: 0 and :heading: -1, or something similar.
> 
> I prefer not to add a style option to the directives. I believe separating structures from styles is a better idea. So the configuration should be separated from "object descriptions". So I'd not like to control (the depth of) the conversion rule manually.

Well, this would exactly be just a structuring option, no styling. But I agree it is rather ugly to put it as a option on directives, so a good default is important. With "put this directive as a subsection of the current section" (i.e., ``-1`` in the terminology above) being the default I believe it is rare that most people needs to explicit add it.
I'm unaware of the current state of development of this enhancement. I have little experience with documentation packages, but I'm aware folks from [scanpy](https://scanpy.readthedocs.io/en/stable/) managed to deal with this issue with an accessory module that achieves this final result.  They use sphinx and a custom theme. Maybe this could work as an inspiration for solving this issue?

Best luck with this enhancement, this is indeed a feature that seems essential for me. 
@davisidarta No, they are using different tricks.

You can see each class is a separate page and it has a heading before class definition actually.  
That heading serves as the TOC entry rather than class itself. This is the workaround that most libraries are using (e.g., pytorch).

You can view my repo docs as a correct example (which uses readthedocs's autoapi extension, but has some bugs as mentioned above): https://ain-soph.github.io/trojanzoo/trojanzoo/datasets.html#trojanzoo.datasets.Dataset

<img width="500" alt="image" src="https://user-images.githubusercontent.com/13214530/157368569-a22bceae-9aab-49da-b67a-9d2b75d17f2e.png">


> You can see each class is a separate page and it has a heading before class definition actually. That heading serves as the TOC entry rather than class itself. This is the workaround that most libraries are using (e.g., pytorch).
>

Ooooh, I see. My bad. 

> You can view my repo docs as a correct example (which uses readthedocs's autoapi extension, but has some bugs as mentioned above): https://ain-soph.github.io/trojanzoo/trojanzoo/datasets.html#trojanzoo.datasets.Dataset
> 

Unfortunately, I could only embed my GIFs and all the documentation in a readable fashion using Sphinx, so I'll have to stick with it. It's too bad, makes it much harder to navigate through large classes with multiple attributes and functions. Hope this feature gets some attention from mantainers soon.

BTW, thank you, I had never received a response to any comment or question on GitHub so hastly.
> Unfortunately, I could only embed my GIFs and all the documentation in a readable fashion using Sphinx, so I'll have to stick with it. It's too bad, makes it much harder to navigate through large classes with multiple attributes and functions. Hope this feature gets some attention from mantainers soon.

readthedocs's autoapi extension is a extention for sphinx (which is the substitution of the default sphinx.autodoc). You are still using sphinx.

[autoapi github repo](https://github.com/readthedocs/sphinx-autoapi)

An example of using it: 
https://github.com/ain-soph/trojanzoo/blob/main/docs/source/conf.py#L68
> > Unfortunately, I could only embed my GIFs and all the documentation in a readable fashion using Sphinx, so I'll have to stick with it. It's too bad, makes it much harder to navigate through large classes with multiple attributes and functions. Hope this feature gets some attention from mantainers soon.
> 
> readthedocs's autoapi extension is a extention for sphinx (which is the substitution of the default sphinx.autodoc). You are still using sphinx.
> 
> [autoapi github repo](https://github.com/readthedocs/sphinx-autoapi)
> 
> An example of using it: https://github.com/ain-soph/trojanzoo/blob/main/docs/source/conf.py#L68

Thank you for this! You're doing God's work (or whatever you believe rules the universe).

I was literally taking some deep-focus time just now working on improving the documentation of [my package](https://topometry.readthedocs.io/) and decided to post this as I was faced with this brick wall. Your response was immediate and very helpful. I wish there was a prize for 'Best GitHub Comment' I could award you with, and I prank not, for this is literally the most helpful comment I've had on GitHub. 
For anyone still trying to this using sphinx to document a python package with *many* class objects and numerous attributes, I've managed it using @ain_soph's suggestion and some of his config file for guidance:

> > Unfortunately, I could only embed my GIFs and all the documentation in a readable fashion using Sphinx, so I'll have to stick with it. It's too bad, makes it much harder to navigate through large classes with multiple attributes and functions. Hope this feature gets some attention from mantainers soon.
> 
> readthedocs's autoapi extension is a extention for sphinx (which is the substitution of the default sphinx.autodoc). You are still using sphinx.
> 
> [autoapi github repo](https://github.com/readthedocs/sphinx-autoapi)
> 
> An example of using it: https://github.com/ain-soph/trojanzoo/blob/main/docs/source/conf.py#L68

The resulting documentation is hosted at [ReadTheDocs](https://topometry.readthedocs.io/en/latest/) using the [sphinx_rtd_theme](https://github.com/readthedocs/sphinx_rtd_theme), and the API sidebar menu lists all methods in the classes. Maybe the [docs/conf.py](https://github.com/davisidarta/topometry/blob/master/docs/conf.py) file can be useful for anyone in a similar situation.

Thanks again @ain-soph for the prompt responses at the time.
Just want to clarify that this issue is still not solved yet. According to my understanding, this issue should aim to create toc entries for classes and functions (rather than sections only)

ReadTheDocs's autoapi extension does support creating TOC entry for each function, class and method, but they always append the entries to the end of existing list, leading to the wrong tree structure (especially when there are sections in the current rst page).  
This limitation is because autoapi is an extension that postprocess the existing TOC entry result which sphinx builds (as @pradyunsg summaries, `Inject the relevant anchors into the env.tocs object`).

Besides, many would still prefer the default `autodoc` over `autoapi`. In that case, one can always use the workaround that instead of creating toc entries for classes and functions, just manually defines sections/subsections before each class and function. This is adopted by many mainstream libraries (e.g., numpy, matplotlib and pytorch).

----------------------------------------------

But I'm confused of the current status, especially about the answer to @pradyunsg 's question https://github.com/sphinx-doc/sphinx/issues/6316#issuecomment-997447806, which option we are finally choosing to implement? `Inject the anchors to existing env.tocs` or `Add discoverability to create the expected env.tocs`?

And since the maintainer has rejected to add style options to directives, then how to change the level? 

Further, the answers to @jakobandersen 's questions https://github.com/sphinx-doc/sphinx/issues/6316#issuecomment-997885030 are still not clear to me yet.
Does anyone have a workaround, such as a gist or a conf.py with vanilla sphinx + `sphinx.ext.autodoc` (not sphinx-autoapi or a another huge system) that can generate the table of contents / headings as a workaround?
> ReadTheDocs's autoapi extension does support creating TOC entry for each function, class and method, but they always append the entries to the end of existing list, leading to the wrong tree structure (especially when there are sections in the current rst page).
This limitation is because autoapi is an extension that postprocess the existing TOC entry result which sphinx builds (as @pradyunsg summaries, Inject the relevant anchors into the env.tocs object).

I'm still trying to understand the code, but is there a reason why it has to be appended to the end. The function that @pradyunsg linked to (https://github.com/readthedocs/sphinx-autoapi/blob/19d217e177d76b40318a30a7cd25195d09530551/autoapi/toctree.py#L123) does do that, but couldn't it be done smarter so that they are inserted in the correct place?
The problem that I wanted to solve was to use the sphinx-formatted function signatures from
```rst
.. py::method:: MyClass.some_method(this, that)
```
as toc-entries instead of requiring header-and-signature like in this image:
![image](https://user-images.githubusercontent.com/1248413/181345170-bd69c85a-ba0b-459e-917d-34091d32a6a2.png)

I didn't want to abuse the existing document structure to wrap signature nodes in sections, as this would produce a broken document (at least, I think so - it would potentially place sections _within_ desc nodes).

I'm not a Sphinx _expert_, but from what I can tell, there is no easy way to replace the ToC generation logic. I opted to write an extension that just re-calculates the ToC after the default extension. It's a proof of concept, so the code is ugly (and adapted from the existing routine):
https://gist.github.com/agoose77/e8f0f8f7d7133e73483ca5c2dd7b907f
I'd happily pay a bounty for this. 

Does the sphinx org accept bounties for issues?

(On both the maintainer's side for their time and whoever PR's a solution?)

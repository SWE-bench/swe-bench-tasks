Just to add to the part of the solution. The 

`self.locations = list(set(locations)) `

in the __init__ method of gettext.py is NOT enough. The 

`def __iter__(self) -> Generator[Message, None, None]:`

needed to have this as well:

`positions = [(os.path.relpath(source, start=os.getcwd()), line) for source, line, uuid in self.metadata[message]]`

The reason being is that there are location lines includes the working directory in the front part of it. This makes the instances of 'relative path' unique while processing, and being duplicated on the output. The correction (computing relative path) above corrected the problem of duplications.

The line causing the problem is with ID:

```
#: ../../manual/compositing/types/converter/combine_separate.rst:121
#: ../../manual/compositing/types/converter/combine_separate.rst:125
#: ../../manual/compositing/types/converter/combine_separate.rst:125
#: ../../manual/compositing/types/converter/combine_separate.rst:153
#: ../../manual/compositing/types/converter/combine_separate.rst:157
#: ../../manual/compositing/types/converter/combine_separate.rst:157
#: ../../manual/compositing/types/converter/combine_separate.rst:40
#: ../../manual/compositing/types/converter/combine_separate.rst:44
#: ../../manual/compositing/types/converter/combine_separate.rst:44
#: ../../manual/compositing/types/converter/combine_separate.rst:89
#: ../../manual/compositing/types/converter/combine_separate.rst:93
#: ../../manual/compositing/types/converter/combine_separate.rst:93
msgid "Input/Output"
msgstr ""
```

I would like to add a further observation on this bug report. When dumping out PO file's content, especially using 'line_width=' parameter and passing in something like 4096 (a very long line, to force the --no-wrap effects from msgmerge of gettext), I found that the locations are ALSO wrapped. 

This is, to my observation, wrong. 

I know some of the locations lines are 'joined' when using 'msgmerge --no-wrap' but this happens, to me, as a result of a bug in the msgmerge implementation, as there are only a few instances in the PO output file where 'locations' are joined by a space. 

This has the effect creating a DIFF entry when submitting changes to repository, when infact, NOTHING has been changed. 

The effect creating unnecessary frustrations for code reviewers and an absolute waste of time. 

I suggest the following modifications in the sphinx's code in the sphinx's code file:

`babel/messages/pofile.py`

 ```
   def _write_comment(comment, prefix=''):
        # xgettext always wraps comments even if --no-wrap is passed;
        # provide the same behaviour
        # if width and width > 0:
        #     _width = width
        # else:
        #     _width = 76

        # this is to avoid empty entries '' to create a blank location entry '#: ' in the location block
        valid = (bool(comment) and len(comment) > 0)
        if not valid:
            return

        # for line in wraptext(comment, _width):
        comment_list = comment.split('\n')
        comment_list = list(set(comment_list))
        comment_list.sort()


    def _write_message(message, prefix=''):
        if isinstance(message.id, (list, tuple)):
            ....
        
        # separate lines using '\n' so it can be split later on
        _write_comment('\n'.join(locs), prefix=':')
```


Next, at times, PO messages should be able to re-order in a sorted manner, for easier to trace the messages. 

There is a built in capability to sort but the 'dump_po' interface does not currently providing a passing mechanism for an option to sort. 

I suggest the interface of 'dump_po' to change to the following in the file:

`sphinx_intl/catalog.py`

```
def dump_po(filename, catalog, line_width=76, sort_output=False):

.....
    # Because babel automatically encode strings, file should be open as binary mode.
    with io.open(filename, 'wb') as f:
        pofile.write_po(f, catalog, line_width, sort_output=sort_output)

```

Good point. Could you send a pull request, please?

Note: I guess the main reason for this trouble is some feature (or extension) does not store the line number for the each message. So it would be better to fix it to know where the message is used.
Hi, Thank you for the suggestion creating pull request. I had the intention of forking the sphinx but not yet know where the repository for babel.messages is. Can you tell me please? 

By the way, in the past I posted a bug report mentioning the **PYTHON_FORMAT** problem, in that this **re.Pattern** causing the problem in recognizing this part **"%50 'one letter'"**  _(diouxXeEfFgGcrs%)_ as an ACCEPTABLE pattern, thus causing the flag "python_format" in the Message class to set, and the **Catalog.dump_po** will insert a **"#, python-format"** in the comment section of the message, causing applications such as PoEdit to flag up as a WRONG format for **"python-format"**. The trick is to insert a **look behind** clause in the **PYTHON_FORMAT** pattern, as an example here:

The old:
```
PYTHON_FORMAT = re.compile(r'''
                \%
                    (?:\(([\w]*)\))?
                    (
                        [-#0\ +]?(?:\*|[\d]+)?
                        (?:\.(?:\*|[\d]+))?
                        [hlL]?
                    )
                    ([diouxXeEfFgGcrs%])                 
            ''', re.VERBOSE)

```
The corrected one:

```
PYTHON_FORMAT = re.compile(r'''
                \%
                    (?:\(([\w]*)\))?
                    (
                        [-#0\ +]?(?:\*|[\d]+)?
                        (?:\.(?:\*|[\d]+))?
                        [hlL]?
                    )
                    ((?<!\s)[diouxXeEfFgGcrs%])  # <<<< the leading look behind for NOT A space "?<!\s)" is required here              
            ''', re.VERBOSE)
```
The reason I mentioned here is to have at least a record of what is problem, just in case. 
Update: The above solution IS NOT ENOUGH. The parsing of PO (load_po) is STILL flagging PYTHON_FORMAT wrongly for messages containing hyperlinks, such as this::

```
#: ../../manual/modeling/geometry_nodes/utilities/accumulate_field.rst:26
#, python-format
msgid "When accumulating integer values, be careful to make sure that there are not too many large values. The maximum integer that Blender stores internally is around 2 billion. After that, values may wrap around and become negative. See `wikipedia <https://en.wikipedia.org/wiki/Integer_%28computer_science%29>`__ for more information."
msgstr ""

```

as you can spot the part **%28c** is causing the flag to set. More testing on this pattern is required.

I don't know if the insertion of a look ahead at the end will be sufficient enough to solve this problem, on testing alone with this string, it appears to work. This is my temporal solution:

```
PYTHON_FORMAT = re.compile(r'''
                \%
                    (?:\(([\w]*)\))?
                    (
                        [-#0\ +]?(?:\*|[\d]+)?
                        (?:\.(?:\*|[\d]+))?
                        [hlL]?
                    )
                    ((?<!\s)[diouxXeEfFgGcrs%])(?=(\s|\b|$))    # <<< ending with look ahead for space, separator or end of line (?=(\s|\b|$)
```
Update: This appears to work:

```
PYTHON_FORMAT = re.compile(r'''
    \%
        (?:\(([\w]*)\))?
        (
            [-#0\ +]?(?:\*|[\d]+)?
            (?:\.(?:\*|[\d]+))?
            [hlL]?
        )
        ((?<!\s)[diouxXeEfFgGcrs%])(?=(\s|$)       #<<< "(?=(\s|$))
''', re.VERBOSE)
```
While debugging and working out changes in the code, I have noticed the style and programming scheme, especially to Message and Catalog classes. I would suggest the following modifications if possible:
- Handlers in separate classes should be created for each message components (msgid, msgstr, comments, flags etc) in separate classes and they all would inherit a Handler base, where commonly shared code are implemented, but functions such as:
> + get text-line recognition pattern (ie. getPattern()), so components (leading flags, text lines, ending signature (ie. line-number for locations) can be parsed separately.
> + parsing function for a block of text (initially file object should be broken into blocks, separated by '\n\n' or empty lines
> + format_output function to format or sorting the output in a particular order.
> + a special handler should parse the content of the first block for Catalog informations, and each component should have its own class as well, (ie. Language, Translation Team etc..). In each class the default information is set so when there are nothing there, the default values are taken instead.
- All Handlers are stacked up in a driving method (ie. in Catalog) in an order so that all comments are placed first then come others for msgid, msgstr etc.. 
- An example from my personal code:
```
ref_handler_list = [
        (RefType.GUILABEL, RefGUILabel),
        (RefType.MENUSELECTION, RefMenu),
        (RefType.ABBR, RefAbbr),
        (RefType.GA_LEADING_SYMBOLS, RefGALeadingSymbols),
        (RefType.GA_EXTERNAL_LINK, RefWithExternalLink),
        (RefType.GA_INTERNAL_LINK, RefWithInternalLink),
        (RefType.REF_WITH_LINK, RefWithLink),
        (RefType.GA, RefGA), # done
        (RefType.KBD, RefKeyboard),
        (RefType.TERM, RefTerm),
        (RefType.AST_QUOTE, RefAST),
        (RefType.FUNCTION, RefFunction),
        (RefType.SNG_QUOTE, RefSingleQuote),
        (RefType.DBL_QUOTE, RefDoubleQuotedText),
        # (RefType.GLOBAL, RefAll), # problem
        (RefType.ARCH_BRACKET, RefBrackets),
    ]

handler_list_raw = list(map(insertRefHandler, RefDriver.ref_handler_list))
handler_list = [handler for handler in handler_list_raw if (handler is not None)]
handler_list = list(map(translate_handler, handler_list))
```
This class separation will allow easier code maintenance and expansions. The current code, as I was debugging through, making changes so difficult and many potential 'catch you' unaware hazards can be found.  
>Hi, Thank you for the suggestion creating pull request. I had the intention of forking the sphinx but not yet know where the repository for babel.messages is. Can you tell me please?

`babel.messages` package is not a part of Sphinx. It's a part of the babel package: https://github.com/python-babel/babel. So please propose your question to their.
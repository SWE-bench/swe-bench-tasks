Subsequently, there is also this behavior with the quotes
```
$ pylint test.py --msg-template='"Category": "{category}"'
************* Module test
Category": "convention
Category": "error
Category": "error
Category": "convention
Category": "convention
Category": "error

$ pylint test.py --msg-template='""Category": "{category}""'
************* Module test
"Category": "convention"
"Category": "error"
"Category": "error"
"Category": "convention"
"Category": "convention"
"Category": "error"
```
Commit that changed the behavior was probably this one: https://github.com/PyCQA/pylint/commit/7c3533ca48e69394391945de1563ef7f639cd27d#diff-76025f0bc82e83cb406321006fbca12c61a10821834a3164620fc17c978f9b7e

And I tested on 2.11.1 that it is working as intended on that version.
Thanks for digging into this !
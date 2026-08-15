Might have similar cause to @classproperty issue described in #7805 
Note: I confirmed with following Dockerfile:
```
FROM python:3.8-slim

RUN apt update; apt install -y git make build-essential vim
RUN git clone https://github.com/pycqa/flake8
WORKDIR /flake8
RUN git checkout 181bb46098dddf7e2d45319ea654b4b4d58c2840
RUN pip3 install tox
RUN tox -e docs --notest
RUN sed --in-place -e 's/-W/-WT/' tox.ini
RUN tox -e docs
```

I got this traceback:
```
Traceback (most recent call last):
  File "/flake8/.tox/docs/lib/python3.8/site-packages/sphinx/events.py", line 110, in emit
    results.append(listener.handler(self.app, *args))
  File "/flake8/.tox/docs/lib/python3.8/site-packages/sphinx/ext/autodoc/type_comment.py", line 125, in update_annotations_using_type_comments
    annotation = type_sig.parameters[param.name].annotation
KeyError: 'kwds'

The above exception was the direct cause of the following exception:

Traceback (most recent call last):
  File "/flake8/.tox/docs/lib/python3.8/site-packages/sphinx/ext/autodoc/__init__.py", line 419, in format_signature
    args = self._call_format_args(**kwargs)
  File "/flake8/.tox/docs/lib/python3.8/site-packages/sphinx/ext/autodoc/__init__.py", line 404, in _call_format_args
    return self.format_args()
  File "/flake8/.tox/docs/lib/python3.8/site-packages/sphinx/ext/autodoc/__init__.py", line 1745, in format_args
    self.env.app.emit('autodoc-before-process-signature', self.object, True)
  File "/flake8/.tox/docs/lib/python3.8/site-packages/sphinx/application.py", line 450, in emit
    return self.events.emit(event, *args, allowed_exceptions=allowed_exceptions)
  File "/flake8/.tox/docs/lib/python3.8/site-packages/sphinx/events.py", line 117, in emit
    raise ExtensionError(__("Handler %r for event %r threw an exception") %
sphinx.errors.ExtensionError: Handler <function update_annotations_using_type_comments at 0x7fe24704fca0> for event 'autodoc-before-process-signature' threw an exception

The above exception was the direct cause of the following exception:

Traceback (most recent call last):
  File "/flake8/.tox/docs/lib/python3.8/site-packages/sphinx/cmd/build.py", line 280, in build_main
    app.build(args.force_all, filenames)
  File "/flake8/.tox/docs/lib/python3.8/site-packages/sphinx/application.py", line 348, in build
    self.builder.build_update()
  File "/flake8/.tox/docs/lib/python3.8/site-packages/sphinx/builders/__init__.py", line 297, in build_update
    self.build(to_build,
  File "/flake8/.tox/docs/lib/python3.8/site-packages/sphinx/builders/__init__.py", line 311, in build
    updated_docnames = set(self.read())
  File "/usr/local/lib/python3.8/contextlib.py", line 120, in __exit__
    next(self.gen)
  File "/flake8/.tox/docs/lib/python3.8/site-packages/sphinx/util/logging.py", line 213, in pending_warnings
    memhandler.flushTo(logger)
  File "/flake8/.tox/docs/lib/python3.8/site-packages/sphinx/util/logging.py", line 178, in flushTo
    logger.handle(record)
  File "/usr/local/lib/python3.8/logging/__init__.py", line 1587, in handle
    self.callHandlers(record)
  File "/usr/local/lib/python3.8/logging/__init__.py", line 1649, in callHandlers
    hdlr.handle(record)
  File "/usr/local/lib/python3.8/logging/__init__.py", line 946, in handle
    rv = self.filter(record)
  File "/usr/local/lib/python3.8/logging/__init__.py", line 807, in filter
    result = f.filter(record)
  File "/flake8/.tox/docs/lib/python3.8/site-packages/sphinx/util/logging.py", line 419, in filter
    raise exc from record.exc_info[1]
sphinx.errors.SphinxWarning: error while formatting arguments for flake8.processor.FileProcessor.inside_multiline:

Warning, treated as error:
error while formatting arguments for flake8.processor.FileProcessor.inside_multiline:
ERROR: InvocationError for command /flake8/.tox/docs/bin/sphinx-build -E -WT -c docs/source/ -b html docs/source/ docs/build/html (exited with code 2)
```
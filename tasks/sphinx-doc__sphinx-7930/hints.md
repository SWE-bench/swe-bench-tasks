Thank you for reporting.

Note: Internally, the autodoc generates the following code:

```
.. py:module:: example


.. py:class:: Report(status: example.Statuses)
   :module: example


   .. py:attribute:: Report.status
      :module: example
      :type: Statuses


.. py:class:: Statuses()
   :module: example
```

It seems the intermediate code is good. But `py:attribute` class does not process `:type: Statuses` option well.
A Dockerfile to reproduce the error:
```
FROM python:3.7-slim

RUN apt update; apt install -y build-essential curl git make unzip vim
RUN curl -LO https://github.com/sphinx-doc/sphinx/files/4890646/sphinx-example.zip
RUN unzip sphinx-example.zip
WORKDIR /sphinx-example
RUN pip install -U sphinx
RUN sphinx-build -NTvv source/ build/html/
```
@tk0miya - It is great to see such open and quick progress. Thank you for your hard work on this.
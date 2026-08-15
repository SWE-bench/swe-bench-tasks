I happened to fix my problem - seems that this occurs when there are both `attribute` and `py:attribute` in the same class with the same name (that occurs because of an unrelated issue with napoleon). I can understand that's not a use case that needs to be supported, but the error thrown should help describe what's going wrong.
Note: reproduced with this dockerfile:
```
FROM python:3.7-slim

RUN apt update; apt install -y git make build-essential vim
RUN git clone https://github.com/gymreklab/TRTools
WORKDIR /TRTools
RUN git checkout 157a332b49f2be0b12c2d5ae38312d83a175a851
RUN apt install -y libz-dev
RUN pip install -e .
RUN pip install -r requirements.txt
WORKDIR /TRTools/doc
RUN pip install Sphinx==3.0.4
RUN echo "autodoc_typehints = 'description'" >> conf.py
RUN make html
```
It seems typo in here. The error is resolved when I replaced `;` to `:`.
https://github.com/gymreklab/TRTools/blob/157a332b49f2be0b12c2d5ae38312d83a175a851/trtools/dumpSTR/filters.py#L596-L599
It seems `Landsat.__orig_bases__` is incorrect. It should be `(RasterDataset, abc.ABC)`. But it returns `(Dataset, abc.ABC)` instead. It must be a bug of Python interpreter.

```
$ python
Python 3.8.12 (default, Sep  3 2021, 02:24:44)
[GCC 10.2.1 20210110] on linux
Type "help", "copyright", "credits" or "license" for more information.
>>> from torchgeo.datasets import Landsat
>>> Landsat.__mro__
(<class 'torchgeo.datasets.Landsat'>, <class 'torchgeo.datasets.RasterDataset'>, <class 'torchgeo.datasets.GeoDataset'>, <class 'torch.utils.data.Dataset'>, <class 'typing.Generic'>, <class 'abc.ABC'>, <class 'object'>)
>>> Landsat.__orig_bases__
(torch.utils.data.Dataset[typing.Dict[str, typing.Any]], <class 'abc.ABC'>)
```

I got the same result with 3.9.7.
```
$ python
Python 3.9.7 (default, Sep  3 2021, 02:02:37)
[GCC 10.2.1 20210110] on linux
Type "help", "copyright", "credits" or "license" for more information.
>>> from torchgeo.datasets import Landsat
>>> Landsat.__mro__
(<class 'torchgeo.datasets.Landsat'>, <class 'torchgeo.datasets.RasterDataset'>, <class 'torchgeo.datasets.GeoDataset'>, <class 'torch.utils.data.Dataset'>, <class 'typing.Generic'>, <class 'abc.ABC'>, <class 'object'>)
>>> Landsat.__orig_bases__
(torch.utils.data.Dataset[typing.Dict[str, typing.Any]], <class 'abc.ABC'>)
```

Note: This is a Dockefile for reproduce.
```
FROM python:3.8-slim

RUN apt update; apt install -y build-essential curl git make unzip vim
RUN git clone https://github.com/microsoft/torchgeo.git
WORKDIR /torchgeo/docs
RUN pip install -r requirements.txt
RUN make html
```
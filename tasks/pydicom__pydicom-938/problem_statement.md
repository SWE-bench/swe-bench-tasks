[python 3.8] failing tests: various issues but "max recursion depth reached" seems to be one
#### Description
Fedora is beginning to test python packages against python 3.8. Pydicom builds but tests fail with errors.

#### Steps/Code to Reproduce

```
python setup.py build
python setup.py install
pytest
```

The complete build log is attached. It includes the complete build process. The root log is also attached. These are the versions of other python libraries that are in use:

```
python3-dateutil-1:2.8.0-5.fc32.noarch
python3-devel-3.8.0~b3-4.fc32.x86_64
python3-numpy-1:1.17.0-3.fc32.x86_64
python3-numpydoc-0.9.1-3.fc32.noarch
python3-pytest-4.6.5-3.fc32.noarch
python3-setuptools-41.0.1-8.fc32.noarch
python3-six-1.12.0-5.fc32.noarch
```

[build-log.txt](https://github.com/pydicom/pydicom/files/3527558/build-log.txt)
[root-log.txt](https://github.com/pydicom/pydicom/files/3527559/root-log.txt)


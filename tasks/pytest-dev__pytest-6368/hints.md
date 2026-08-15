Copying the output from https://github.com/pytest-dev/pytest-mock/issues/167#issuecomment-548662953:

Output from dist-info:

```
file: pytest_mock-1.11.3.dev2+g1c5e8e9.d20191031.dist-info/INSTALLER; module_or_pkg_name: []
file: pytest_mock-1.11.3.dev2+g1c5e8e9.d20191031.dist-info/LICENSE; module_or_pkg_name: []
file: pytest_mock-1.11.3.dev2+g1c5e8e9.d20191031.dist-info/METADATA; module_or_pkg_name: []
file: pytest_mock-1.11.3.dev2+g1c5e8e9.d20191031.dist-info/RECORD; module_or_pkg_name: []
file: pytest_mock-1.11.3.dev2+g1c5e8e9.d20191031.dist-info/WHEEL; module_or_pkg_name: []
file: pytest_mock-1.11.3.dev2+g1c5e8e9.d20191031.dist-info/entry_points.txt; module_or_pkg_name: []
file: pytest_mock-1.11.3.dev2+g1c5e8e9.d20191031.dist-info/top_level.txt; module_or_pkg_name: []
file: pytest_mock/__init__.py; module_or_pkg_name: ['pytest_mock'] <---------- Good!
file: pytest_mock/__pycache__/__init__.cpython-36.pyc; module_or_pkg_name: []
file: pytest_mock/__pycache__/_version.cpython-36.pyc; module_or_pkg_name: []
file: pytest_mock/__pycache__/plugin.cpython-36.pyc; module_or_pkg_name: []
file: pytest_mock/_version.py; module_or_pkg_name: []
file: pytest_mock/plugin.py; module_or_pkg_name: []
```

From egg:

```
file: .gitignore; module_or_pkg_name: []
file: .pre-commit-config.yaml; module_or_pkg_name: []
file: CHANGELOG.rst; module_or_pkg_name: []
file: HOWTORELEASE.rst; module_or_pkg_name: []
file: LICENSE; module_or_pkg_name: []
file: README.rst; module_or_pkg_name: []
file: setup.cfg; module_or_pkg_name: []
file: setup.py; module_or_pkg_name: ['setup'] <-------- ?????????????
file: tox.ini; module_or_pkg_name: []
file: .github/FUNDING.yml; module_or_pkg_name: []
file: .github/workflows/main.yml; module_or_pkg_name: []
file: src/pytest_mock/__init__.py; module_or_pkg_name: [] <-------- Hey, why u ditch me?
file: src/pytest_mock/_version.py; module_or_pkg_name: []
file: src/pytest_mock/plugin.py; module_or_pkg_name: []
file: src/pytest_mock.egg-info/PKG-INFO; module_or_pkg_name: []
file: src/pytest_mock.egg-info/SOURCES.txt; module_or_pkg_name: []
file: src/pytest_mock.egg-info/dependency_links.txt; module_or_pkg_name: []
file: src/pytest_mock.egg-info/entry_points.txt; module_or_pkg_name: []
file: src/pytest_mock.egg-info/requires.txt; module_or_pkg_name: []
file: src/pytest_mock.egg-info/top_level.txt; module_or_pkg_name: []
file: tests/test_pytest_mock.py; module_or_pkg_name: []
```
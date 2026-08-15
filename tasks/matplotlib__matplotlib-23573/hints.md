One can always readjust `cls.__module__` post-hoc; setting `__all__` appropriately may also help with sphinx.
(A single `axes.py` would be sufficiently enormous that I think keeping a split implementation is more manageable.)
Might be worth checking out http://sphinx-automodapi.readthedocs.io/en/latest/ in the long run, which automatically does module documentation and includes everything.
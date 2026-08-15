@mhvk , numpy-dev is failing now; e.g. https://travis-ci.org/astropy/astropy/jobs/536308798

```
________________________ TestUfuncHelpers.test_coverage ________________________
self = <astropy.units.tests.test_quantity_ufuncs.TestUfuncHelpers object at 0x7f11069a17b8>
    def test_coverage(self):
        """Test that we cover all ufunc's"""
    
        all_np_ufuncs = set([ufunc for ufunc in np.core.umath.__dict__.values()
                             if isinstance(ufunc, np.ufunc)])
    
        all_q_ufuncs = (qh.UNSUPPORTED_UFUNCS |
                        set(qh.UFUNC_HELPERS.keys()))
        # Check that every numpy ufunc is covered.
>       assert all_np_ufuncs - all_q_ufuncs == set()
E       AssertionError: assert {<ufunc 'clip'>} == set()
E         Extra items in the left set:
E         <ufunc 'clip'>
E         Use -v to get the full diff
astropy/units/tests/test_quantity_ufuncs.py:69: AssertionError
```
OK, I'll try to have a fix soon...
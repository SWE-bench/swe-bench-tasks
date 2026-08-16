Invalid variable lookup when walrus operator is used
### Steps to reproduce
1. Consider following code in `loop_error.py`:
	```
    """Test module"""


	def walrus_in_comprehension_test_2(some_path, module_namespace):
	    """Suspected error"""
	    for mod in some_path.iterdir():
	        print(mod)
	
	    for org_mod in some_path.iterdir():
	        if org_mod.is_dir():
	            if mod := module_namespace.get_mod_from_alias(org_mod.name):
	                new_name = mod.name
	            else:
	                new_name = org_mod.name
	
	            print(new_name)
	```
2. Run `pylint ./loop_error.py`

### Current behavior
A warning appears: ```W0631: Using possibly undefined loop variable 'mod' (undefined-loop-variable)```

### Expected behavior
No warning, because the variable `mod` is always defined.

### `python -c "from astroid import __pkginfo__; print(__pkginfo__.version)"` output
- 2.14.1
- 2.15.0-dev0 on 56a65daf1ba391cc85d1a32a8802cfd0c7b7b2ab with Python 3.10.6

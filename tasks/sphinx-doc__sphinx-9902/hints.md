I did also want to mention the use of :py:class:`Unit` does not work in the :type: option field. 
Yet it does work when specifying the type for a parameter of a function.

I have also placed the import of "Unit" before the docstring and explicitly set the docstring to __doc__ and that did not work either. 

Reproduced with this:
```
.. py:module:: my_library.module2

.. py:class:: Unit

.. py:module:: my_library.module1

.. py:data:: mol
   :type: Unit
   :value: 'mol'

   mole
```

In this case, ```:py:class:`Unit` ``` inside `my_library.module1` module is also not working because its module is different with `my_library.module2`. ```:py:class:`.Unit` ``` is working. But `:type:` field does not allow `.Unit` notation. So this must be a bug.
Thanks for the report. I attached a regression test. Reproduced at c498f088c584ec3aff97409fdc11b39b28240de9.
Regression test.
I *think* I'm getting a similar (or same) error when adding lowercased ordering to a model via meta: class Recipe(models.Model): # ... class Meta: ordering = (Lower('name'),) This works fine in normal views (listing out recipes for instance), but in the admin, I get the following error: 'Lower' object is not subscriptable which also comes via get_order_dir()
Yes that's the same issue, thanks for another scenario to reproduce it.
​https://github.com/django/django/pull/11489
​PR
In 8c5f9906: Fixed #30557 -- Fixed crash of ordering by ptr fields when Meta.ordering contains expressions.
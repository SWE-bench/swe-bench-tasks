Hello Olivier, I think you should be able to achieve this by defining a count() method on the dynamic class created by create_forward_many_to_many_manager by filtering self.through._default_manager based on self.instance and return its count().
Thanks for your advice. I will try to correct it according to your advice Replying to Simon Charette: Hello Olivier, I think you should be able to achieve this by defining a count() method on the dynamic class created by create_forward_many_to_many_manager by filtering self.through._default_manager based on self.instance and return its count().
​https://github.com/django/django/pull/10366
Have we considered making this change for exists() as well? I'm sure this will generate the join in the same way that count() does. Also somewhat related: #28477
Doing it for exists() as well makes sense.
In 1299421: Fixed #29725 -- Removed unnecessary join in QuerySet.count() and exists() on a many-to-many relation.
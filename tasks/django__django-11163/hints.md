model_to_dict() is a part of private API. Do you have any real use case for passing empty list to this method?
​PR
This method is comfortable to fetch instance fields values without touching ForeignKey fields. List of fields to be fetched is an attr of the class, which can be overridden in subclasses and is empty list by default Also, patch been proposed is in chime with docstring and common logic
​PR
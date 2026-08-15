​https://github.com/django/django/pull/12923
OK, yes, let's provisionally Accept this: I think it's probably correct. (At this level we're avoiding DB errors, not business logic errors, like "was this archived", which properly belong to the form layer...)
I take it the change here is ORM rather than forms per se.
I take it the change here is ORM rather than forms per se. Makes sense. This is a change to model validation to allow the form validation to work.
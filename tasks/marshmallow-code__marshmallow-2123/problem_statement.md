fields.URL should allow relative-only validation
Relative URLs may be used to redirect the user within the site, such as to sign in, and allowing absolute URLs without extra validation opens up a possibility of nefarious redirects.

Current `fields.URL(relative = True)` allows relative URLs _in addition_ to absolute URLs, so one must set up extra validation to catch either all absolute URLs or just those that don't have a valid domain names.

It would be helpful if there was a way to set up URL validation to allow only relative URLs. 

~One quick and dirty way to do this would be if there was a `validate.Not` operator, then at the expense of matching the value twice, it would be possible to use something like this:~

~`fields.URL(relative = True, validate=validate.Not(validate.URL()))`~

EDIT: Never mind the crossed out thought above - failed validations are handled only via exceptions and while failing the inner validator works in general, it requires suppressing exception handlers and is just not a good way to go about it. 

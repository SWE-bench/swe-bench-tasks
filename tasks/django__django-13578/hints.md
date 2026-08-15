validation error with _errors included
Not sure I completely agree with the suggested fix, but yes -- the error on failure of the management form could be a little more helpful, at the very least naming the field that is missing or invalid.
Patch would need improvement as per Russell's comment. Also needs tests.
Change UI/UX from NULL to False.
Change Easy pickings from NULL to False.
We may change the code from : raise ValidationError( _('ManagementForm data is missing or has been tampered with'), code='missing_management_form', ) to something like: raise ValidationError( _('ManagementForm data is missing or has been tampered with %s' % form._errors), code='missing_management_form', ) Approvals please.
​PR
On second thought I suppose it’s a bit early for the needs tests flag since no one has supplied a review.
don't add delete field to formset extra forms
newer diff with edit to forms.models to avoid error on save
I thought brosner already had done this. Seems a valid issue, anyway.
Having lived with this for a while, I can see the case where one might want a delete field on extra forms. I'd still argue that it shouldn't be the default, but it could be another option on formsets. Perhaps delete_extra or extra_delete?
I don't think this is the case on trunk anymore. I don't see delete checkboxes for "add" forms.
The delete fields still appear here on all rows with the latest trunk, r11468. from django import forms class Form(forms.Form): test = forms.CharField() FormSet = forms.formsets.formset_factory(Form, can_delete=1) formset = FormSet(initial=[{'test':'Some initial data for the first row'}]) The formset contains two rows, both of which have a delete checkbox.
updated patch for 1.3.1
Change UI/UX from NULL to False.
Change Easy pickings from NULL to False.
While I can understand how from a usability perspective this could be confusing, the ability to delete can also be a useful way to discard a new form entry rather than having to clear each populated field for the given form(s). As a result, I propose adding a can_delete_extra option to formsets, which allow developers to decide whether they wish to omit deletion fields from their formsets without having to write any any additional logic in to their templates/views. I'm about to attach the relevant patches. If accepted, I'm happy to provide a patch to public documentation for reference also.
Latest 'before' test to confirm behaviour
Potential solution by adding in 'can_delete_extra' option
Tests introduced to ensure all is well following introduction of potential solution
​PR
Left comments for improvement on the PR.
Addressed points raised in PR (4772) and opened new PR (5323) as advised.
Thanks for the updating patch. After you do so, don't forget to uncheck "Patch needs improvement" so the ticket returns to the review queue. I'll leave it checked for now as we've hit the feature freeze for 1.9 and the patch will need to be updated for 1.10 once we cut the stable/1.9.x branch this week.
Thanks Tim, I've updated the version number in the associated documentation from 1.9 to 1.10 accordingly. I'll update the ticket once the automated builds have succeeded.
The new option should be available on model formsets too.
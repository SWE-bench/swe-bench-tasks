Initial patch, probably needs tests.
Updated patch to apply to current trunk and added a test for the history view.
Marking as DDN until an answer to ticket:14358#comment:3 is provided.
The objection was "for debug purposes, it would be more useful to have the field names, as they are necessarily unique, untranslated, etc." In my opinion: uniqueness is a weak argument: if you have two fields with the same name, you're just asking for trouble; translation isn't an issue at all: in doubt, just switch the website to the default language of your codebase.
#14358 is a duplicate and has patches too.
Patch will need to be updated to apply cleanly.
A Github pull request (​#4496) has been opened for this ticket.
I am thinking it might be best to try to address #21113 first (allow messages to be translated to the current language rather than displaying the language that was active for editing) since this ticket would require a new implementation for that one.
Left comments for improvement on the PR.
I think it's better to work with the form labels than fields' verbose name, I think It's actually a more natural flow and more consistent if the label is different then the verbose name. (That's the idea behind the field label option, right?!) My Approach would be to gather the changed fields' labels, then send it to get_text_list ​https://github.com/django/django/blob/master/django/contrib/admin/options.py#L925-L936 translated_changed_fields = [form.fields[f].label for f in form.changed_data] change_message.append(_('Changed %s.') % get_text_list(translated_changed_fields, _('and'))) #again for formset for changed_object, changed_fields in formset.changed_objects: translated_changed_fields = [formset.forms[0].fields[f].label for f in changed_fields] #using formset.forms[0] looks ugly i agree , couldn't find better ways But hey , it's a changed formset , index [0] is there ! change_message.append(_('Changed %(list)s for %(name)s "%(object)s".') % {'list': get_text_list(translated_changed_fields, _('and')), #... Created a duplicate 24990 Regards;
It seems to me that the verbose name is a safer choice to account for the fact that you might have several different editing forms each with a different label.
IMHO, that depend on the intended audience of the changed message in the history. If it's the developer then verbose_name are the way to go. If it's the site 'content' administrator, this is what i think is the case, then labels are more of expected behavior; and in that case the "maybe different" verbose name can be confused as a bug. "I edited the field "More info", why does it show me that i edited 'description' which is not even present on the form ?" :) Kind regards;
I see that this pull request didn't get merged. I can go for it with the form label resolution.
After further consideration, I think that approach is okay.
PR created ​#5169
I left some comments for improvement on the pull request. Don't forget to uncheck "Patch needs improvement" on this ticket after you update it so it appears in the review queue, thanks!
Some ​discussion on the mailing list confirmed my feeling that we should fix #21113 first.
I'm trying to modify the current patch and apply it cleanly to the current master branch.
​PR
Comments left on the PR.
I've addressed the reviews. Can you please take another pass?
Review comments have been addressed. Patch looks good to go. (Will just leave time for Claude to follow up if he wants to.)
Addressed Claude's review on the patch and it is ready for a review again and possibly check-in.
There were just a couple more comments on the ticket. Sanyam, please uncheck Patch needs improvement when you've had a look at those. (Thanks for the great effort!)
Hey Carlton, I've addressed the last nit-picks in the patch. Thank you for your patience!
Hello, Can you please have a look at the recent updates on this patch? Please let me know if any more changes are needed. Thanks!
(The patch is in the review queue, no need to add a comment asking for a review. I was on vacation last week and am catching up on things.)
PR looks not far off after several reviews. Once comments are addressed it would be good if previous reviewers could give one more look to make sure we don't miss anything.
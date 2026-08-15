This ticket tracks a sub-part of this deprecation process - https://code.djangoproject.com/ticket/27064
My understanding is that we're keeping the AlterIndexTogether migration operation around indefinitely for support in historical migrations. Are there any other details from our conversations to add?
Yes, since AlterIndexTogether is currently there in the migrations of so many Django projects we need to keep maintaining it. But the idea is to deprecate the use of index_together in the models file and the generate_altered_index_together method of the MigrationAutodetector.
Changed the keywords by mistake.
working on this ticket during duth sprint
see ​https://github.com/django/django/pull/7509 any comment appreciated
I left comments for improvement.
While this is the one step of the deprecation process of index_together there is currently no way to migrate an existing from index_together to indexes w/o dropping and recreating indexes. Since removing and adding an index can be a quite expensive operation, this is not an option to do so for now. The next step in the deprecation process needs to treat indexes and index_together similarly in the sense that the latter is translated into the former internally (inside the migration framework). Once this is done, the deprecation of actually using index_together can start.
Hi Markus, Thank you for your reply. Are you referring to #27064 ? or is it something different ?
I think that's the correct ticket.
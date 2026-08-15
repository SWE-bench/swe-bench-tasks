Thank you for the report. The problem you ran into relates to the fact that the migration internally don't care about case sensitivity of model names (ProjectState.models has a dictionary whose keys are (app_label, model_name) where the latter is lower cased). Your work around seems to be valid. I'd need more info to figure out why adding the RenameModel manually fails.
Sorry for the delayed response. I did not realize my e-mail address was missing from the preferences. Is there anything I can do to provide more info on the RenameModel failure?
See #25429 for a probable duplicate (but please check when this is fixed and reopen it if not).
#26752 seems to be another symptom (closed as duplicate, but reopen if not).
This is a duplicate of #27297
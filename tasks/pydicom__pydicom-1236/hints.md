For some reason when I wrote it, I assumed it was a case of either/or for *VOI LUT Sequence*/*Window Center*, but now that I look at the Standard again I see it possible that both can be present (although only one can be applied). I'll probably add a flag to allow selecting which one is used when both are present.
> If both LUT and WL are supplied, by the dicom standard, which should be applied?

That should be up to the user

> Separately to the above question about which is applied, if both LUT and WL sequences are supplied, is there a way in apply_voi_lut to specify applying one or the other? (ie force application of the WL instead of LUT etc)

Not at the moment, although you could force which is applied by deleting the corresponding element(s) for the operation you don't want

> Also, if an image has a sequence of WL values rather than being single valued (so 0028,1050 & 0028,1051 are sequences), does the index parameter to apply_voi_lut apply to specify which in the sequence you want to use?

Yes
Is it possible that you could attach an anonymised dataset we could add to our test data? It'd be helpful to have a real dataset.

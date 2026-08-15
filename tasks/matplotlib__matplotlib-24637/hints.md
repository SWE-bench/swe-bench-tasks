Seems reasonable.  AnnotationBBox has a few artists in it, so I don't think it will get a unique ID?   But certainly they could get ids...
Thanks for the reply. Yes, I wondered if I'd need to set different ids for the artists in AnnotationBBox or if I could have one id for the annotation as a whole. Either would be useful when editing the svg later.

Thanks,

Lauren
I'd say AnnotationBbox.draw should just call open_group() at the beginning and close_group() at the end, i.e. wrap the entire AnnotationBbox in a svg element with that gid.
Marking as good first issue as the solution is more or less given. Still, some read-up on SVG specification and testing required.
Discussed this with @saranti at the pydata global sprint.
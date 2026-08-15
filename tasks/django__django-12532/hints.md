It's a slight inconsistency, sure, but they are two different fields, so different error message keys are reasonable. Pushing post-1.0.
Milestone post-1.0 deleted
Change UI/UX from NULL to False.
Change Easy pickings from NULL to False.
Should this change happen? The comments are ambiguous :)
The implementation isn't difficult (see attached patch). The question is whether or not we accept this as a backwards incompatible change (to be documented if so) or try for some deprecation path. I'm not sure how a deprecation would work.
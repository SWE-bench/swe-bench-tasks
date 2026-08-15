thanks for spotting this
(1) OPTICS was introduced in 0.21, so we don't need to consider python2. maybe use int(...) directly?
(2) please fix similar issues in cluster_optics_xi
(3) please update the doc of min_samples in compute_optics_graph
(4) please add some tests
(5) please add what's new
Where shall the what's new go? (this PR, the commit message, ...)? Actually it's just the expected behavior, given the documentation

Regarding the test:
I couldn't think of a test that checks the (not anymore existing) error besides just running optics with floating point parameters for min_samples and min_cluster_size and asserting true is it ran ...
Is comparing with an integer parameter example possible?
(thought the epsilon selection and different choices in initialization would make the algorithm and esp. the labeling non-deterministic but bijective.. with more time reading the tests that are there i ll probably figure it out)

Advise is very welcome!
> Where shall the what's new go?

Please add an entry to the change log at `doc/whats_new/v0.21.rst`. Like the other entries there, please reference this pull request with `:pr:` and credit yourself (and other contributors if applicable) with `:user:`.
ping we you are ready for another review. please avoid irrelevant changes.
Just added the what's new part, ready for review
ping
Also please resolve conflicts.
@someusername1, are you able to respond to the reviews to complete this work? We would like to include it in 0.21.3 which should be released next week.
Have a presentation tomorrow concerning my bachelor's.
I m going to do it over the weekend (think it ll be already finished by Friday).
We're going to be releasing 0.21.3 in the coming week, so an update here would be great.
Updated
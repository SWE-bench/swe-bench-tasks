I'm not sure I understand the use case. For what would the parseable one (e.g JSON) will be used for in CI?
We are currently in the process of setting up a pipeline for checking a project for "sanity". I though having a job evaluating the pylint score given in the final report. Having the job emit a warning when the value falls below a certain threshold. Additionally the value could be emitted to something like grafana or kibana to visualise the evolution of code "health".

As the project is fairly big, the pylint execution takes a while. Having the output in a parseable file would open up quite a lot of possibilities for CI pipelines.

However, when enabling the parseable output, there is no "human readable" output anymore on the console. But this is super useful to have in pipelines which are executed on a headless server. If a job fails, I get an e-mail with the link to the failing job and can see the stdout of it.

If I enable parseable output for more advanced pipeline jobs I lose that.

Unless I would execute the job twice. Once with parseable output and one with colorised terminal output. But that would be a waste of time.
I think I could see a potential value in this change, but this will require a bit of refactoring through out the outputting logic, for which, to be honest, I am afraid I won't have time right now. If you have time to work it out and send a PR, that would be great.
I agree. I have quite a lot on my plate as well at the moment so I can't promise anything soonish, but I will try to have a look.

Do you have any pointers where I should look first? Or do you have any thoughts on how to begin working on this?

For me an open question is "backwards compatibility" because this will touch the "external API" of pylint. I don't want to break anything if anyone already does some sort of parsing of the pylint output... I will think of something...
After reading the [document about lint.Run and lint.Pylinter](https://pylint.readthedocs.io/en/latest/technical_reference/startup.html) I was thinking about the following strategy:

* make `lint.Run` create some new form of "Reporter" instance(s). These would represent the reports requested by the end-user
* make `lint.Run` pass these reporters to `lint.Lint`
* replace existing reporting functionality in `lint.Lint`with the construction of a well-defined data-object which is then passed to each of the aforementioned reporters.

@PCManticore what do you think about that? I'm still letting this idea simmer a bit in my head, but I think this should be doable.
This seems doable, but I'm not sure we actually want to have this feature in pylint itself.
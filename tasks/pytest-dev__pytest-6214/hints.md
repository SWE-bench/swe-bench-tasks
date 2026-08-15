Hi @oscarh,
could you state your expectations a little bit clearer? Are you surprised, that in your first output, the setup and teardown is announced more often than they would actually occur? I try to have a look into it over the weekend, but as far I remember, it was not straightforward to arrange the fixtures at this point of collection.

Hi @sallner,

Sorry about the late reply. As you have guessed, I was surprised that the setup and teardown are printed more ofter than they're executed. In other words, the plan, and what happens seem to differ.
This is really confusing. While both `--setup-show` and `--setup-only` display the setup correctly, `--setup-plan` makes no sense.
The plugin implementing this is https://github.com/pytest-dev/pytest/blob/cc464f6b96e59deafbe1e393beba7a21351c2e9d/src/_pytest/setupplan.py - in case you want to investigate / fix this.
Hi @oscarh,
could you state your expectations a little bit clearer? Are you surprised, that in your first output, the setup and teardown is announced more often than they would actually occur? I try to have a look into it over the weekend, but as far I remember, it was not straightforward to arrange the fixtures at this point of collection.

Hi @sallner,

Sorry about the late reply. As you have guessed, I was surprised that the setup and teardown are printed more ofter than they're executed. In other words, the plan, and what happens seem to differ.
This is really confusing. While both `--setup-show` and `--setup-only` display the setup correctly, `--setup-plan` makes no sense.
The plugin implementing this is https://github.com/pytest-dev/pytest/blob/cc464f6b96e59deafbe1e393beba7a21351c2e9d/src/_pytest/setupplan.py - in case you want to investigate / fix this.
Why not redirecting pylint command in your tox file into a file?

@PCManticore Because (and this was new to me as I hadn't tried before) [`tox` does not support file redirection](https://bitbucket.org/hpk42/tox/issues/73/pipe-output-of-command-into-file), so there is no way to do it that I am aware of.

Hello,

I've the same problem when running pylint inside tox. And also this is more complicated once you need to develop a multiplatform application.

The only way to save the pylint stdout inside a file, is to tell tox to use bash or cmd, according with the platform, with '>' operator. Unfortunately, there's not a way to do so but creating multiple tox environments once for each platform, that is (of course) a huge waste of space and time.

Perhaps makes the automation system really complicated and difficult to handle.
Thanks for the input @acerv It seems this will be definitely useful, so I'd be happy to reintegrate a `--file-output` functionality for the entire output.
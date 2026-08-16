In addition, I don't understand what the purpose of the `config.debug` function since the default behavor of the logging module in absence of configuartion seems to already be the one you want.

From https://docs.python.org/3/howto/logging.html#configuring-logging-for-a-library:

> If the using application does not use logging, and library code makes logging calls, then (as described in the previous section) events of severity WARNING and greater will be printed to sys.stderr. This is regarded as the best default behaviour.

and

>**It is strongly advised that you do not add any handlers other than NullHandler to your library’s loggers.** This is because the configuration of handlers is the prerogative of the application developer who uses your library. The application developer knows their target audience and what handlers are most appropriate for their application: if you add handlers ‘under the hood’, you might well interfere with their ability to carry out unit tests and deliver logs which suit their requirements. 

I think you make good points here.  I support changing the logging to comply with python's suggested behavior.

> In addition, I don't understand what the purpose of the config.debug function

One reason is that the core loop in pydicom (data_element_generator in filereader.py) is extremely optimized for speed - it checks the `debugging` flag set by config.debug, to avoid composing messages and doing function calls to logger when not needed.
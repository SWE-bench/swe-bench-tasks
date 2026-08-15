A possible workaround would be available if PEP 415 (__suppress_context__) were respected.
Can you please give code to reproduce the issue?
In a view, with DEBUG = True. try: raise RuntimeError('outer') from RuntimeError('inner') except RuntimeError as exc: raise exc.__cause__
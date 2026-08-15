I'll ensure to include the filename in the warning, this is another fatal flaw of the warning system 
Ah, I agree this is somewhat of a problem with Python warnings. The location is indeed included when showing them as normal warnings, but not when turning them into exceptions (via `filterwarnings = error` or `-Werror`.
i will make warn_explicit_for handle this better
I'll ensure to include the filename in the warning, this is another fatal flaw of the warning system 
Ah, I agree this is somewhat of a problem with Python warnings. The location is indeed included when showing them as normal warnings, but not when turning them into exceptions (via `filterwarnings = error` or `-Werror`.
i will make warn_explicit_for handle this better
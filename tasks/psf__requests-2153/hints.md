Thanks so much for this! :cake:

This looks like a good catch. I think the generator created in `Response.iter_content` should probably be looking for Timeout errors, both from urllib3 and from the socket module, and should catch and wrap them. @sigmavirus24?

Sounds like a good idea to me

i think this is the underlying issue in urllib3: https://github.com/shazow/urllib3/pull/297

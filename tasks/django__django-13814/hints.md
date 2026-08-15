Invalid error message.
good error message.
I'm not sure if the "helpful" message added in 655f52491505932ef04264de2bce21a03f3a7cd0 must be removed, but since master only supports Python 3, there's an opportunity to use Python 3 exception chaining, e.g. raise InvalidTemplateLibrary(...) from e.
No, this looks like an error.

`iter_content` doesn't seem to expect any socket errors, but it should. We need to fix this.

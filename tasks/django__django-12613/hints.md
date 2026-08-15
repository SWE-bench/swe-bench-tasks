Thanks for the report. I was able to reproduce this issue. Reproduced at a9179ab032cda80801e7f67ef20db5ee60989f21.
How *should* JSONField serialize into XML? Should it be serialized first into JSON then inserted into the node as a string? Should the Python data structure just be put as a string into the node? Something more complicated?
​PR
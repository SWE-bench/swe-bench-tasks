_From Konstantin Molchanov on 2012-12-11 17:30:16+00:00_

Vital feature, please add!

Note: #175
Now we provides a config variable `highlight_options` to pass options to pygments since v1.3. I think it can resolve this case. Please let me know if you'd like to apply options to an arbitrary code-block.

BTW, the `highlight_options` are only applied to the language that is specified to `highlight_language`. It means we can't pass the options to pygments when using two or more languages. It should be improved before closing this.
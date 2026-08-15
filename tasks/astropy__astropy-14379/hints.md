isn't it good form to always have a space between the value and the unit?
:+1: for consistency between Quantity and Angle (by having space as default).

However, if you worry about backward compatibility, maybe instead add an option for "old style" (without space), but would that be useful for anyone?
Well the one place where we *don't* want a space is when using a symbol, e.g. ``3.4"``
Re: symbol -- Nothing some `regex` wouldn't fix... :wink: (*show self to door*)
 @astrofrog I think we should use a space by default (probably the most common use case), and then add a boolean keyword argument to optionally not include a space (e.g. `3.4"`).
I agree!
can i work on this
> 👍 for consistency between Quantity and Angle (by having space as default).
> 
> However, if you worry about backward compatibility, maybe instead add an option for "old style" (without space), but would that be useful for anyone?

@pllim I have implemented your idea in the PR attached; please see to it.
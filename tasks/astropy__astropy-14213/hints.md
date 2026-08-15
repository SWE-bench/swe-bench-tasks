Hmm, definitely an oversight; I do remember being quite fed up by the time I got to `histogram` as it had so many options... Anyway, I guess to fix this one needs to add treatment to https://github.com/astropy/astropy/blob/87963074a50b14626fbd825536f384a6e96835af/astropy/units/quantity_helper/function_helpers.py#L666-L687

Of course, also need to fix the other ones; maybe a small `_check_range` function would do the trick (in analogy with `_check_bins`).
Ok, thanks for looking into this. I will open a PR shortly with my attempt
at a fix.

On Wed, Dec 21, 2022, 12:13 PM Marten van Kerkwijk ***@***.***>
wrote:

> Hmm, definitely an oversight; I do remember being quite fed up by the time
> I got to histogram as it had so many options... Anyway, I guess to fix
> this one needs to add treatment to
> https://github.com/astropy/astropy/blob/87963074a50b14626fbd825536f384a6e96835af/astropy/units/quantity_helper/function_helpers.py#L666-L687
>
> Of course, also need to fix the other ones; maybe a small _check_range
> function would do the trick (in analogy with _check_bins).
>
> —
> Reply to this email directly, view it on GitHub
> <https://github.com/astropy/astropy/issues/14209#issuecomment-1361957695>,
> or unsubscribe
> <https://github.com/notifications/unsubscribe-auth/AAUTD5JS33DYNNOMXQ4GCN3WONJF5ANCNFSM6AAAAAATF4BFD4>
> .
> You are receiving this because you authored the thread.Message ID:
> ***@***.***>
>

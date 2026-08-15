My vote is to raise BlackHoleSingularityError.

On Tue, Apr 2, 2019 at 8:58 PM Andreas Mueller <notifications@github.com>
wrote:

> Bug report
>
> *Bug summary*
>
> Zero-width figure crashes libpng.
> This happens when using %matplotlib inline or saving to png.
>
> *Code for reproduction*
>
> import matplotlib.pyplot as plt
> plt.subplots(1, 1, figsize=(3, 0))
> plt.savefig("test.png")
>
> *Actual outcome*
>
> RuntimeError: libpng signaled error
>
> *Matplotlib version*
>
>    - Operating system: ubuntu / conda
>    - Matplotlib version: 3.0.2, conda
>
> Apparently I broke "conda list" on my machine so getting all the versions
> seems a bit tricky.
>
> —
> You are receiving this because you are subscribed to this thread.
> Reply to this email directly, view it on GitHub
> <https://github.com/matplotlib/matplotlib/issues/13857>, or mute the
> thread
> <https://github.com/notifications/unsubscribe-auth/AARy-Lhb7Oq4mWRv142sFRO_JnntAhx1ks5vc_zDgaJpZM4cZZc1>
> .
>

In all seriousness, though, this should be easy enough to detect and raise
in the Figure class. I can't imagine how a figsize with a 0-length
dimension would ever be anything but an error.

On Tue, Apr 2, 2019 at 10:12 PM Benjamin Root <ben.v.root@gmail.com> wrote:

> My vote is to raise BlackHoleSingularityError.
>
> On Tue, Apr 2, 2019 at 8:58 PM Andreas Mueller <notifications@github.com>
> wrote:
>
>> Bug report
>>
>> *Bug summary*
>>
>> Zero-width figure crashes libpng.
>> This happens when using %matplotlib inline or saving to png.
>>
>> *Code for reproduction*
>>
>> import matplotlib.pyplot as plt
>> plt.subplots(1, 1, figsize=(3, 0))
>> plt.savefig("test.png")
>>
>> *Actual outcome*
>>
>> RuntimeError: libpng signaled error
>>
>> *Matplotlib version*
>>
>>    - Operating system: ubuntu / conda
>>    - Matplotlib version: 3.0.2, conda
>>
>> Apparently I broke "conda list" on my machine so getting all the versions
>> seems a bit tricky.
>>
>> —
>> You are receiving this because you are subscribed to this thread.
>> Reply to this email directly, view it on GitHub
>> <https://github.com/matplotlib/matplotlib/issues/13857>, or mute the
>> thread
>> <https://github.com/notifications/unsubscribe-auth/AARy-Lhb7Oq4mWRv142sFRO_JnntAhx1ks5vc_zDgaJpZM4cZZc1>
>> .
>>
>

yeah totally fine with an error. doing zero height works btw ?!
I guess the expected behavior that I didn't specify is "either create an empty figure or raise an informative error".
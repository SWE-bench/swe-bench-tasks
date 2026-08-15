Adding a warning might be noisier than useful as events get connected and
disconnected all the time. We should see if we are regularly firing events
after disconnects or not. But I can see how this could be useful for
debugging.

On Jul 4, 2017 11:32 AM, "David Stansby" <notifications@github.com> wrote:

> Bug report
>
> If fig.canvas.mpl_connect is passed an invalid event type string, it
> silently does nothing. I think there should at least be a warning (maybe an
> error?)
>
> *Code for reproduction*
>
> import matplotlib.pyplot as plt
>
> fig, ax = plt.subplots()def onclick(event):
>     print('Event!')
> cid = fig.canvas.mpl_connect('invalid_event_string', onclick)
> plt.show()
>
> *Actual outcome*
>
> Clicking around or doing or trying to trigger onclick() does nothing.
>
> *Expected outcome*
>
> I would expect a warning if 'invalid_event_string' isn't one of the
> strings listed at http://matplotlib.org/devdocs/
> api/backend_bases_api.html?highlight=mpl_connect#matplotlib.backend_bases.
> FigureCanvasBase.mpl_connect
>
> *Matplotlib version*
>
>    - Matplotlib Version: master installed from source using pip
>
> —
> You are receiving this because you are subscribed to this thread.
> Reply to this email directly, view it on GitHub
> <https://github.com/matplotlib/matplotlib/issues/8839>, or mute the thread
> <https://github.com/notifications/unsubscribe-auth/AARy-JNEYD1iLc19seb4BxF2Op2fEgu_ks5sKlsMgaJpZM4ONfXo>
> .
>

The callback registries do not know what keys they are going to get (which I think is a feature!), but adding an optional set of expected keys to the registry init + warning or error on invalid keys is a reasonable idea.
No, I was thinking more along the lines of issuing a warning for unknown
events on the emit call. Although, now that I think of it, that wouldn't
help for connecting to built-in events.

On Jul 5, 2017 4:03 PM, "Thomas A Caswell" <notifications@github.com> wrote:

> The callback registries do not know what keys they are going to get (which
> I think is a feature!), but adding an optional set of expected keys to the
> registry init + warning or error on invalid keys is a reasonable idea.
>
> —
> You are receiving this because you commented.
> Reply to this email directly, view it on GitHub
> <https://github.com/matplotlib/matplotlib/issues/8839#issuecomment-313211155>,
> or mute the thread
> <https://github.com/notifications/unsubscribe-auth/AARy-HgcXt7ANz0Pgj2RSB75Q-EQMJnmks5sK-wkgaJpZM4ONfXo>
> .
>

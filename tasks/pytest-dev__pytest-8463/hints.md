Sorry I missed this issue.

So if I understand correctly, the issue is about *invoking* the hooks, rather than implementing them.

The hooks affected are:

- `pytest_ignore_collect`
- `pytest_collect_file`
- `pytest_pycollect_makemodule`
- `pytest_report_header`
- `pytest_report_collectionfinish`

Before we go and try to revert the changes (or just accept them), I'd like to audit plugins to see if this is an issue in practice, i.e. if there are plugins which actually *invoke* these, and how difficult it will be to make them compatible. Usually of course, only pytest invokes its hooks. I'll try to do it soon. If you already know of any plugins which do this let me know.
i'm aware of at least `pytest_sugar`

i couldn't do a deeper audit myself yet

i would consider it fitting to do a major version bump for this one and just calling it a day

cc @nicoddemus for opinions on that

of course pr's for plugins we know of should also help
I looked at my corpus of 680 plugins and found 6 cases:

```
pytest-mutagen/src/pytest_mutagen/plugin.py
48:            return ihook.pytest_pycollect_makemodule(path=path, parent=parent)

pytest-sugar/pytest_sugar.py
250:        lines = self.config.hook.pytest_report_header(

pytest-tldr/pytest_tldr.py
158:            headers = self.config.hook.pytest_report_header(

pytest-idapro/pytest_idapro/plugin_internal.py
180:        self.config.hook.pytest_report_header(config=self.config,

pytest-it/src/pytest_it/plugin.py
257:        lines = self.config.hook.pytest_report_collectionfinish(

pytest-litf/pytest_litf.py
241:        lines = self.config.hook.pytest_report_collectionfinish(
```

I think I can send PRs for them.

Besides, I think we shouldn't guarantee API stability for *invoking* hooks. Seems to me pluggy was carefully designed to allow it, and that it would be an overall negative to freeze all hooks.

I don't think this should require a major bump.

WDYT?
its a major release, we break apis

as for pluggy, the current suggestion is **new api gets **new hook name**, deprecating the old hook name
pluggy was not carefully designed to allow it, in fact when we tried to layer it into pluggy it turned out to be very complex

in my book new api same hook name is a  breaking change
pytest never says that invoking its own hooks is stable API. Hook-invoking is not documented anywhere, except in the "write your hooks" section. It seems to me an unreasonable backward compatibility burden to guarantee this.

Advantages of defining new hooks:
- Plugins which invoke the modified hooks keep working without update.

Disadvantages:
- Defining multiple hooks which do the same thing breaks things like `try_first` and hook wrappers, which *are* covered by stability guarantees.
- Adds mental overhead for plugin authors.
- Causes forward compat problems.

On balance, I think we shouldn't define new hooks, and we should document that invoking our own hooks has this compat hazard.
i agree that we shouldn't  define new hooks, but let me be very clear, this is a breaking api change, it must get a major bump.
its an exposed api that never had a potential instability as part of a external contract

if we had hook invocation as a private property, i'd agree with the minor bump, but it is a public attribute, it gets a major bump

> i agree that we shouldn't define new hooks

Thanks.

> its an exposed api that never had a potential instability as part of a external contract

This part I don't really agree with. I think the rule for this case should be "we never said it was public, therefore it's not", and not "we never said it was *not* public, therefore it is".

It is really difficult to develop a project if you have to assume all internal details are public-by-default, especially in Python. So when a plugin is using an undocumented API, they have to be prepared for breakage.

It will also be very difficult to develop pytest if you have to assume that core hooks may be invoked by external plugins. When I develop I assume that core hooks are only invoked by core.

The reason I'm against just doing a major version bump is that it will be a major discouragement from ever adding new args to hooks, which will hamper making improvements.

> if we had hook invocation as a private property, i'd agree with the minor bump, but it is a public attribute, it gets a major bump

The hook invocation mechanism must be public because users are free to define their own hooks.
I see nothing wrong with major version bumps, even many times

Again we break a api that is incidentally exposed as public, so its a major version, i don't see any room to argue on this

The only alternative I'm open to discuss there is using calver instead 



Hey folks,

I don't see a problem with doing a major bump, even if we use that opportunity to say that from that version onward, calling those hooks is subject to future breakages, so be prepared. We don't have to consider that just because we are assuming a breaking API change and doing a major bump, that forever now we need to keep the same API stable. We can do a major bump, break the API, and mark it as unstable. One approach doesn't exclude the other.

Moving forward, do we want to mark those hooks as "unstable" to be called by plugins?


i really don't like the idea of "unstable apis" there - no matter how you document unstable, its going to eats some peoples code

i'd rather do a major release when we have to change a hook, 
So what I'm going to do it finish the existing changed I made, revert 592b32bd69cb43aace8cd5525fa0b3712ee767be so it doesn't block the release or force a major release, and write a comment on what work remains to get rid of py.path.
@bluetech again, its absolutely fine to do a major release and i don't like to undo this work !
In situations like this I always prefer to revert first to fix the blocker instead of it being a fait accompli...
I don't follow what the blocker is then 
I'm also OK with releasing 7.0.0rc1.

However I worry this problem is not documented anywhere. We should add a backward incompatible note, and also a big changelog entry, before releasing anything: users are often upset by breakages, even more so if there's no communication of the rationale or how to fix the breakage.
> I don't follow what the blocker is then

I think for 7.x we should have the py.path (pending)deprecation situation in order, which is not the case yet. In the meanwhile it would be rude of me to leave master in an un-realeasable state.
> I think for 7.x we should have the py.path (pending)deprecation situation in order

Ahh I see thanks. But what do you see as "pending"? I think we might have different perceptions here.
Mostly what I wrote here: https://github.com/pytest-dev/pytest/pull/8251#issuecomment-796852908
Ahh thanks, I missed that. Can we turn that into an issue?




@bluetech @nicoddemus i have an idea for a potential solution,

im wireing up a POC now that will get us backward-compatibility
This is intended, so that it's clear that something failed in the past even with longer outputs.
@iurisilvio this is expected behaviour. It won't work with absolute name (i.e. `blueprint_name.func`) either. What are you trying to do exactly? Probably you should use `request.url` instead of `url_for`.

@jackunion it was just an example. I want to mount the same blueprint with different prefixes and I expect my _relative_ `url_for` to work inside my blueprint, but this is not how it works.

I fixed my problem with multiple blueprints (with the same routes), but I expected `url_for` working fine with blueprints.

Flask store the blueprint in a dict like `dict[blueprint.name] = blueprint`. I can change the blueprint name before register the blueprint again and it works (or override the `app.register_blueprint` to avoid name collision). I'm not sure if it really works.

@iurisilvio actually, `url_for` works just fine :]
Try `print(app.url_map)` to see all url rules.

I am really curious what you're trying to do with registering the same blueprint multiple times. The restriction might seem arbitrary, but i can imagine it is in place to avoid gross misuse of Flask's blueprints.

> Register a blueprint multiple times on an application with different URL rules.

From http://flask.pocoo.org/docs/blueprints/

> @iurisilvio this is expected behaviour. It won't work with absolute name (i.e. blueprint_name.func) either.

That is not true. This is not expected behaviour, this is a supported use case.

@danielchatfield have you read the question?

Yes. The docs give registering a single blueprint multiple times on the same app as an "intended use case".

The utility of that is somewhat questionable if `url_for` doesn't work properly.

@untitaker I have a blueprint mounted in `/foo`, but I also want almost the same views in routes like  `/x/foo` and `/y/foo`, where `x` and `y` are sections of my app. Some users can view only `x` section, which contains lots of routes from other blueprints too. Other users can view `x`, `y` and the `/foo`, which contains data from both sections and some other things.

In most cases, I'd prefer `/something/x` and `/something/y`, but this is not the case, `x` and `y` are used in several parts of my app and really makes sense in this case.

I just created a blueprint factory to fix this issue for me, using different names. It works fine and is not a huge problem for me. But I consider it a bug, because it is an intended use case (@danielchatfield already quoted it). I never expected a relative `url_for` returning something from other mounted blueprint.

First, i have to admit that it indeed seems to be an intended usecase.

 @iurisilvio It basically seems like you're mixing code and data there. Adding a rule `/<section>/foo` and using a proper data storage for the sections seems better at first glance, but i don't want to say your solution is wrong since i don't know your usecase.

Yes, I agree. This structure is weird, but it is really the right choice for my app.

As I said, it was easy to workaround this issue, but if I rather mount the same blueprint in different paths. Blueprints are perfect to my use case, based on blueprint definition. Unfortunately, `url_for` breaks all my url references. Looks like a bug or at least docs deserve better explanation about this limitation.

@danielchatfield this question is about `url_for`, not about registering multiple blueprints.

@jackunion this issue is about the `url_for` behaviour with the same blueprint registered more than once.

Two statements from blueprints docs:

> Register a blueprint multiple times on an application with different URL rules.
> 
> Additionally if you are in a view function of a blueprint or a rendered template and you want to link to another endpoint of the same blueprint, you can use relative redirects by prefixing the endpoint with a dot only

@iurisilvio and again:
`url_for` will not work as you expect even with absolute name (i.e. blueprint_name.view_func), not only with relative name.
It will give you the wrong url even if your blueprint is registered once but have more than one route decorator (i.e `@blueprint_name.route()`).
If you want to know how exactly `url_for` builds url, start [here](https://github.com/mitsuhiko/flask/blob/master/flask/helpers.py#L186).

@jackunion the point of this issue is that it is a bug.

@jackunion we know it doesn't work, but as per the docs it should work!

Hmm, this is definitely unexpected behavior, but I'm not sure what we can do about it. The problem is that the endpoint becomes `foo.func`, and while Werkzeug knows all the rules associated with an endpoint, it only uses the first one to build with.

There's no information about which path to prefer. We'd need to send the url prefix to `MapAdapter.build` and use that when deciding which rule to use for the endpoint.

There's also no way to know what other prefixes a blueprint was registered under, so we can't know a prefix to strip and replace with the current blueprint.
This is really confusing. The same `Register a blueprint multiple times on an application with different URL rules` line in the docs let me to expect that utilities like `url_for` would still work, but they don't.

My solution was to just nest my blueprint creation and route definition inside a `make_blueprint(blueprint_name)` factory function that could pass different `name` parameters to each `Blueprint` instance ...
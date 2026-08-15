There are some bootstrap code in `FlaskGroup.main()`, so I think it is not allowed to nest it in another group, because the function is never called.
Ah, interesting. Could there be any workaround for this to be allowed? I guess at the end `Flask` should be fully compatible with all `click` functionalities (group `nesting` being one of the main ones).
Passing create_app as a parameter doesn't work in this case, but you can still use FLASK_APP environment variable to do the trick. Note that some functionalities are still missing, such as dotenv loading.
I also came across this issue, I dug into the source and was able to make a minor change which *seems* to do the trick. I have yet to test it more thoroughly however, perhaps someone here can figure out if this affects something else.

Quite simply I re-write FlaskGroup and replace `main` with `make_context` (naturally, the call and the `super()`) here https://github.com/pallets/flask/blob/master/src/flask/cli.py#L578-L597

This is because in click, one of the first things that are done in `main` is to call `make_context` with `kwargs` (https://github.com/pallets/click/blob/master/src/click/core.py#L809)

Which ends up here: https://github.com/pallets/click/blob/35f73b8c2c314e56968de8bc483da9a84ac5c53e/src/click/core.py#L712 
It looks to me like injecting kwargs into this function instead of main should work just as well. In my simple tests, this seems to enable me to run the flask apps using the new FlaskGroup in sub groups.

After additional testing I may consider writing a PR if no one beats me to it.
@u8sand Thanks a lot for your research!

For anyone else wondering how to avoid this issue, this is the code I used (simplified a bit):

```python3
class CustomGroup(FlaskGroup):
    def make_context(self, *args, **extra):
        obj = extra.get("obj")
        if obj is None:
            obj = ScriptInfo(create_app=self.create_app, set_debug_flag=self.set_debug_flag)
        extra["obj"] = obj

        return super().make_context(*args, **extra)

@click.group(cls=CustomGroup)
...
````
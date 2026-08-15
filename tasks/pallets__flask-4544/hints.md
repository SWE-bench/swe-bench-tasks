I am humbled to share my findings using `click`. Apparently, the order of arguments being passed to the `cli` seems to matter in `click`(not sure whether or not it is intentional).  I've found that the context manager only keeps track of the first option being passed. Take the following as an example:

```python
import click

options = set()

def orders_params(ctx, param, value):
    global options
    print(ctx.params.items())
    options.add((param, value))

@click.command()
@click.option("--foo", required=True, multiple=True, callback=orders_params)
@click.option("--bar", required=True, multiple=True, callback=orders_params)
def run_command(*, foo, bar):
    print("Parameters order:")
    for param, val in options:
        print("   " + param.name + str(val))

if __name__ == "__main__":
    run_command()
```

After running the above script, it generates different results depending on the ordering:

```sh
(.venv) ➜  ✗ python3 cli.py --foo foo --bar bar
dict_items([])
dict_items([('foo', None)])
Parameters order:
   bar('bar',)
   foo('foo',)

(.venv) ➜  ✗ python3 cli.py --bar bar --foo foo
dict_items([])
dict_items([('bar', None)])
Parameters order:
   foo('foo',)
   bar('bar',)
```

As you may notice, the output generated from the first command, the `ctx` object holds only the first option ` foo` after two callbacks being triggered. Similarly, the `ctx` object in the command contains only the first option `bar`.

With that noted, running `flask run --cert foo.cert --key foo.pem` and `flask run --key foo.pem --cert foo.cert` would result in different behavious.

Running the latter would result in `cert` being `None`:

https://github.com/pallets/flask/blob/4843590c4a7f2225fd18bd10963139a6f29a2a59/src/flask/cli.py#L723

And it will trigger the following case:

https://github.com/pallets/flask/blob/4843590c4a7f2225fd18bd10963139a6f29a2a59/src/flask/cli.py#L738-L739

IMHO, adding support for this edge case would require overriding the `parse_args` method of the `click.Command` and passing it in the decorator.

```python
@click.command(..., cls=OrderParams)
                                   ^___ this argument
```

and OrderParams is some kind of class that inherits from `click.Command` to override the `parse_args` method.

```python
class OrderParams(click.Command)
  parse_args(self, ctx: click.core.Context, args: List[str]) -> List[str]:
    # custom logic goes here
```

Hopefully, the above info can help resolve the issue.
Well, it's worth making the `_validate_cert` function. And for `--cert` option set `callback=_validate_cert`. Just a humble guess
No, implementing custom `Command.parse_args` is not the way to solve this.
@davidism, how do you like my thoughts?
Now I thought that this is not very good, because. the code is almost identical to `_validate_key`...
I also wanted to add that I didn't mean to change the option type, I just want to add a new callback without changing the option type for `--cert`
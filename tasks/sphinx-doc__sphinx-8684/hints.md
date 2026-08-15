Hi,
assuming to pass the _unsplitted_ code, I guess we could think to modify 

```
def dedent_lines(lines, dedent):
    if not dedent:
        return lines

    new_lines = []
    for line in lines:
        new_line = line[dedent:]
        if line.endswith('\n') and not new_line:
            new_line = '\n'  # keep CRLF
        new_lines.append(new_line)

    return new_lines
```

with 

```
import textwrap

def dedent_lines(lines, dedent):
    if dedent==0 or not dedent:
        return lines

   if dedent == -1:
    return textwrap.dedent(lines)


    new_lines = []
    for line in lines:
        new_line = line[dedent:]
        if line.endswith('\n') and not new_line:
            new_line = '\n'  # keep CRLF
        new_lines.append(new_line)

    return '\n'.join(new_lines)
```

In this way
- using `:dedent:` equals to `-1` we obtain a maximal dedent
- we do nothing if `:dedent:` is 0 or not passed, saving time
- we dedent using standard Python without the need to know how many spaces must be remove.

The original intent of `:dedent:` was, as you describe, to remove all common leading whitespace as seen in #939 where @shimizukawa talks about it as a boolean option. For some reason, the code subsequently merged by @zsiddiqui2 (commit a425949c360a0f6c0f910ada0bc8baec3452a154) added it as an integer and it has been kept this way ever since.

I reckon that it is very error-prone to specify an integer which, as it is implemented now, eats characters from the left independently of whether they are whitespace characters or not. I have two solutions which are more sain in my opinion:
1. Keep `:dedent:` as an integer, but interpret it as a maximum dedentation level. It will then remove leading characters up untill the first non-whitespace character or the specified maximum is reached. Non-negative values will behave as now with added robustness.  Default is zero (no dedentation). Negative values means no maximum (giving the requested behavior).
2. Reimplement `:dedent:` as a flag and use the standard `textwrap.dedent()` function as a replacement for the custom made `dedent_lines()` function. This will add support for tabs as well, but breaks backwards compatibility. If backwards compatibility is a must, we could still make a `:dedent-auto:` alternative with this functionality.

I have no problem making a pull request for this issue if someone will take up the discussion and tell me the preferred solutions.
If it were for my personal taste I will agree with point 2 and make `dedent`  behave as the corresponding Python function

https://docs.python.org/3.1/library/textwrap.html#textwrap.dedent


I am in need of this functionality as it is impractical to have o find the indent of the specific code block. If any indent changes are made to the code, this will break the docs or make it look bad. using :dedent-auto: seems like a decent solution imo, but it can't dedent all lines using the textwrap.dedent(). When I tried that, this was the result:
before:
```
    def func():
        some_code
```
will look like this:
```
def func():
some_code
```
when it should be this: 
```
def func():
    some_code
```
It would be better to change the argument of `:dedent:` optional. And it behaves like `textwrap.dedent()` when no argument passed. Of course, it behaves as is when we passed an integer as an argument.
I did find a work-around for this for my project, but I still think this is a nice to have enhancement.
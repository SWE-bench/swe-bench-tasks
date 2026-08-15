Confirmed. It seems better not to send `Accept:` header to GitHub. On the other hand, some server requires the header (see #5140). So it would be better to allow to customize it via code or configuration.

Just an idea, `linkcheck_request_header` might be helpful for such case:
```
linkcheck_request_header = {
    '*': {'Accept': 'text/html,application/xhtml+xml;q=0.9,*/*;q=0.8',}
    'https://github.com': {},
    ...
}
```
@tk0miya this looks like a good idea.
Oops, I've overlooked to work for this issue on the 3.0 release... I just set the milestone for this issue now.
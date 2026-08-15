Can I see a bit of sample code? I suspect you're passing a Unicode string somewhere. 

Good call. To reproduce this, you need both a unicode method and an https url, eg

```
python -c 'import requests; s = requests.Session(); r = requests.Request(u"POST", "https://httpbin.org/post"); pr = s.prepare_request(r); print s.send(pr).content'
```

In my case, the unicode method comes from [this line](https://github.com/hickford/MechanicalSoup/blob/0dd97c237cbad16e7c3f6a46dcbd6f067b319652/mechanicalsoup/browser.py#L36) in a library I'm using.

So, this is strictly a regression IMO: requests is supposed to handle this reasonably correctly. Clearly we regressed that somewhere down the line. I'll see if I can get a fix for this into 2.8.1.

The reason we regressed this is because urllib3's PyOpenSSL compatibility layer started using memoryviews. I think we can likely only reproduce this bug when using that, but we were definitely doing this wrong and should fix it.

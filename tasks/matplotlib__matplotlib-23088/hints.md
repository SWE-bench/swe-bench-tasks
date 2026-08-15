I'm not really sure what we can do here.  Unfortunately we also support `ax.plot('boo', '-r', data=df)` to plot with `df['boo']` as the y data (x data is assumed np.arange(len(y))), and  `'-r'` as the format string.  We definitely don't want to warn on `data['-r']` - instead we just assume `'-r'` is a format string and carry on.  

Given this flexibility, I think the error message is as helpful as it can be: Matplotlib is considering your second string as a format string, and it is illegal. Where in doubt, or debugging, users are always encouraged to be explicit: `ax.plot(df['header'], df['correctlySpelledHeader'])` raises: 
```
KeyError: 'correctlySpelledHeader'
```

Someone could try to fix this by checking if the second string is a valid formatting string, but then it is ambiguous whether the error should be a KeyError or a ValueError.  I'd vote that this is a "can't fix".  

I was unaware of why, but assumed there was a reason this was allowed to pass through. I guess my comment is that understanding that the format string error message could be related to a key error in your data is pretty esoteric and hostile to a new user trying to do a basic task and making a very common error.

for example my situation of finding this is using a simulation framework that uses matplotlib to plot results. So a user writes a model which registers the output(typo here) which lets the framework write the data to a csv. The framework calls pandas to make the dataframe, the framework calls matplotlib to plot using the correct spelling, and then the error occurs.

so I have a smart user out there, with a wealth of knowledge just no matplotlib knowledge. But because the typo occurred miles away, and the message has nothing to do with the error, a user has to spend an hour or more learning matplotlib’s various functionalities and hunting this down.

now, I will make the suggestion that the framework adopt the approach:

ax.plot( df[<header string>]…

as opposed to:

ax.plot(<header string>….data=df…

Which is fine for the framework developers to be expected to have pretty decent knowledge of a library they employ. But again, I think this behavior is hostile to new users.
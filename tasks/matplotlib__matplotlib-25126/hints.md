I can confirm that this is a regression between 3.6.2 and 3.6.3, is still present in 3.7.0rc1 and is not a pdf related problem.

Slightly modified reproduction script:

```python

import numpy as np
import matplotlib
import matplotlib.pyplot as plt

samples = np.random.normal(size = 1000)
x = np.linspace(-5,5,1000)
fig, ax = plt.subplots()
ax.set_title(f'{matplotlib.__version__}')
ax.hist(samples, log = True, density = True)
ax.plot(x, np.exp(-x**2/2)/np.sqrt(2*np.pi))
fig.savefig('/tmp/log.pdf')
plt.pause(1)
ax.set_yscale('linear')
plt.pause(1)
fig.savefig('/tmp/lin.pdf')
```

Thank you for the very clear report @sterinaldi !
bisects to 8d8d3f5c11a6e086e53163a6986a771f5b11f5bc (#24684)

which is the (manual) backport of #24654

Also interacts with #24634, which was modifying some of the same areas of code

Cache invalidation strikes again
Interestingly, the original PR (#24654) explicitly mentions the "fix log/linear toggle", and states that it "clearly works fine even with this removal"
It matters if there is a draw before the switch.  Commenting out the save and the pause makes the linear one look correct.

Further linear -> log works, but log -> linear does not...
ok, I  have a fix for this and see how to test it, PR coming soon.
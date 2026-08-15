This is fixed by https://github.com/matplotlib/matplotlib/pull/22828 (?) although a test is required to get it merged.

I'm not sure that your code for reproduction actually shows the right thing though as Matplotlib is not involved.
> This is fixed by #22828 (?) although a test is required to get it merged.

 #22828  seems only deal with the problem of `mode == 'magnitude'`, not `mode == 'psd'`.
I not familiar with **complex** window coefficients, but I wonder  if `np.abs(window).sum()` is really the correct scale factor? As it obviously can't fall back to real value case.
Also, the  implementation of scipy seems didn't consider such thing at all.

> I'm not sure that your code for reproduction actually shows the right thing though as Matplotlib is not involved.

Yeah, it is just a quick demo of the main idea, not a proper code for reproduction.
The following is a comparison with `scipy.signal`:
```python
import numpy as np
from scipy import signal
from matplotlib import mlab

fs = 1000
f = 100
t = np.arange(0, 1, 1/fs)
s = np.sin(2 * np.pi * f * t)

def window_check(window, s=s, fs=fs):
    psd, freqs = mlab.psd(s, NFFT=len(window), Fs=fs, window=window, scale_by_freq=False)
    freqs1, psd1 = signal.welch(s, nperseg=len(window), fs=fs, detrend=False, noverlap=0,
                                window=window, scaling = 'spectrum')
    relative_error = np.abs( 2 * (psd-psd1)/(psd + psd1) )
    return relative_error.max()

window_hann = signal.windows.hann(512)
print(window_check(window_hann))   # 1.9722338156434746e-09

window_flattop = signal.windows.flattop(512)
print(window_check(window_flattop)) # 0.3053349179712752
```
> #22828 seems only deal with the problem of `mode == 'magnitude'`, not `mode == 'psd'`.

Ah, sorry about that.

> Yeah, it is just a quick demo of the main idea, not a proper code for reproduction.

Thanks! I kind of thought so, but wanted to be sure I wasn't missing anything.

It indeed seems like the complex window coefficients causes a bit of issues... I wonder if we simply should drop support for that. (It is also likely that the whole mlab module will be deprecated and dropped, but since that will take a while... In that case it will resurrect as, part of, a separate package.)
@gapplef Can you clarify what is wrong in the Matplotlb output?

```python
fig, ax = plt.subplots()
Pxx, f = mlab.psd(x, Fs=1, NFFT=512, window=scisig.get_window('flattop', 512), noverlap=256, detrend='mean')
f2, Pxx2 = scisig.welch(x, fs=1, nperseg=512, window='flattop', noverlap=256, detrend='constant')
ax.loglog(f, Pxx)
ax.loglog(f2, Pxx2)
ax.set_title(f'{np.var(x)} {np.sum(Pxx[1:] * np.median(np.diff(f)))} {np.sum(Pxx2[1:] * np.median(np.diff(f2)))}')
ax.set_ylim(1e-2, 100)
```
give exactly the same answers to machine precision, so its not clear what the concern is here?  
@jklymak 
For **real** value of window, `np.abs(window)**2 == window**2`, while  `np.abs(window).sum()**2  != window.sum()**2`.
That's why your code didn't show the problem. To trigger the bug, you need `mode = 'psd'` and `scale_by_freq = False`.

The following is a minimal modified version of your code:
```python
fig, ax = plt.subplots()
Pxx, f = mlab.psd(x, Fs=1, NFFT=512, window=scisig.get_window('flattop', 512), noverlap=256, detrend='mean', 
                  scale_by_freq=False)
f2, Pxx2 = scisig.welch(x, fs=1, nperseg=512, window='flattop', noverlap=256, detrend='constant', 
                  scaling = 'spectrum')
ax.loglog(f, Pxx)
ax.loglog(f2, Pxx2)
ax.set_title(f'{np.var(x)} {np.sum(Pxx[1:] * np.median(np.diff(f)))} {np.sum(Pxx2[1:] * np.median(np.diff(f2)))}')
ax.set_ylim(1e-2, 100)
```
I agree those are different, but a) that wasn't what you changed in #22828.  b) is it clear which is correct?  The current code and script is fine for all-positive windows.  For windows with negative co-efficients, I'm not sure I understand why you would want the sum squared versus the abs value of the sum squared.  Do you have a reference?  Emperically, the flattop in scipy does not converge to the boxcar if you use scaling='spectrum'.  Ours does not either, but both seem wrong.  
Its hard to get excited about any of these corrections:

```python
import numpy as np
from scipy import signal as scisig
from matplotlib import mlab
import matplotlib.pyplot as plt

np.random.seed(11221)
x = np.random.randn(1024*200)
y = np.random.randn(1024*200)
fig, ax = plt.subplots()


for nn, other in enumerate(['flattop', 'hann', 'parzen']):
    Pxx0, f0 = mlab.psd(x, Fs=1, NFFT=512,
                    window=scisig.get_window('boxcar', 512),
                    noverlap=256, detrend='mean',
                    scale_by_freq=False)
    Pxx, f = mlab.psd(x, Fs=1, NFFT=512,
                    window=scisig.get_window(other, 512),
                    noverlap=256, detrend='mean',
                    scale_by_freq=False)
    f2, Pxx2 = scisig.welch(y, fs=1, nperseg=512, window=other,
                            noverlap=256, detrend='constant',
                            scaling='spectrum')
    f3, Pxx3 = scisig.welch(y, fs=1, nperseg=512, window='boxcar',
                            noverlap=256, detrend='constant',
                            scaling='spectrum',)

    if nn == 0:
        ax.loglog(f0, Pxx0, '--', color='0.5', label='mlab boxcar')
        ax.loglog(f2, Pxx3, color='0.5', label='scipy boxcar')

    ax.loglog(f, Pxx, '--', color=f'C{nn}', label=f'mlab {other}')
    ax.loglog(f2, Pxx2, color=f'C{nn}', label=f'scipy {other}')
    ax.set_title(f'{np.var(x):1.3e} {np.sum(Pxx0[1:] * np.median(np.diff(f))):1.3e} {np.sum(Pxx[1:] * np.median(np.diff(f))):1.3e} {np.sum(Pxx2[1:] * np.median(np.diff(f2))):1.3e}')
    ax.set_ylim(1e-3, 1e-1)
    ax.legend()
plt.show()
```
![widnowcorrection](https://user-images.githubusercontent.com/1562854/215683962-cf75b8a5-26a0-45d9-8d9c-7f445a16267f.png)

Note that if you use spectral density, these all lie right on top of each other.  

https://www.mathworks.com/matlabcentral/answers/372516-calculate-windowing-correction-factor

seems to indicate that the sum is the right thing to use, but I haven't looked up the reference for that, and whether it should really be the absolute value of the sum.  And I'm too tired to do the math right now.  The quoted value for the correction of the flattop is consistent with what is being suggested.  

However, my take-home from this is never plot the amplitude spectrum, but rather the spectral density.  

Finally, I don't know who wanted complex windows.  I don't think there is such a thing, and I can't imagine what sensible thing that would do to a real-signal spectrum.  Maybe there are complex windows that get used for complex-signal spectra?  I've not heard of that, but I guess it's possible to wrap information between the real and imaginary.  

- #22828 has nothing to do me.
  It's not my pull request. Actually, I would suggest ignore the complex case, and simply drop the `np.abs()`, similar to what `scipy` did.

- I think the result of `scipy` is correct.
To my understanding, [Equivalent Noise Bandwidth](https://www.mathworks.com/help/signal/ref/enbw.html#btricdb-3) of window $w_n$ with sampling frequency $f_s$ is
  $$\text{ENBW} = f_s\frac{\sum |w_n|^2}{|\sum w_n|^2}$$ 
  + For `spectrum`:
    $$P(f_k) = \left|\frac{X_k}{W_0}\right|^2 = \left|\frac{X_k}{\sum w_n}\right|^2$$
    and with `boxcar` window, $P(f_k) = \left|\frac{X_k}{N}\right|^2$
  + For `spectral density`:
    $$S(f_k) = \frac{P(f_k)}{\text{ENBW}} = \frac{|X_k|^2}{f_s \sum |w_n|^2}$$
    and with `boxcar` window,  $S(f_k) = \frac{|X_k|^2}{f_s N}$.

Those result are consistent with the implementation of [`scipy`](https://github.com/scipy/scipy/blob/d9f75db82fdffef06187c9d8d2f0f5b36c7a791b/scipy/signal/_spectral_py.py#L1854-L1859) and valid for both `flattop` and `boxcar`. For reference, you may also check out the window functions part of [this ducument](https://holometer.fnal.gov/GH_FFT.pdf).

- Also, I have no idea of what complex windows is used for, and no such thing mentioned in [wikipedia](https://en.wikipedia.org/wiki/Window_function). But I am not an expert in signal processing, so I can't draw any conclusion on this.
I agree with those being the definitions - not sure I understand why anyone would use 'spectrum' if it gives such biased results.  

The code in question came in at https://github.com/matplotlib/matplotlib/pull/4593. It looks to be just a mistake and have nothing to do with complex windows.  

Note this is only an issue for windows with negative co-efficients - the old implementation was fine for windows as far as I can tell with all co-efficients greater than zero.  

@gapplef any interest in opening a PR with the fix to `_spectral_helper`?  
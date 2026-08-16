See #1673 
@cedricleroy can you provide the inputs and function call that produced the negative `v_oc` shown above?
@echedey-ls Thanks! I thought I checked for related issues, but apparently not enough 😄 

@cwhanse Sure thing:

Running [`_lambertw_v_from_i` in `_lambertw`](https://github.com/pvlib/pvlib-python/blob/v0.9.4/pvlib/singlediode.py#L639-L641) with the following data:

```
    resistance_shunt  resistance_series    nNsVth  current  saturation_current  photocurrent          v_oc
0        8000.000000              0.178  1.797559      0.0        1.480501e-11      0.000000  8.306577e-16
1        8000.000000              0.178  1.797048      0.0        1.456894e-11      0.000000 -7.399531e-15
2        8000.000000              0.178  1.791427      0.0        1.220053e-11      0.000000  2.289847e-15
3        8000.000000              0.178  1.789892      0.0        1.162201e-11      0.000000  3.357630e-15
4        8000.000000              0.178  1.790915      0.0        1.200467e-11      0.000000  8.885291e-16
5        7384.475098              0.178  1.796786      0.0        1.444902e-11      0.237291  4.222001e+01
6        5023.829590              0.178  1.814643      0.0        2.524836e-11      1.458354  4.495480e+01
7        2817.370605              0.178  1.841772      0.0        5.803733e-11      3.774055  4.584869e+01
8        1943.591919              0.178  1.877364      0.0        1.682954e-10      6.225446  4.567622e+01
9        1609.391479              0.178  1.910984      0.0        4.479085e-10      8.887444  4.530535e+01
10       1504.273193              0.178  1.937034      0.0        9.402419e-10     11.248103  4.494422e+01
11       1482.143799              0.178  1.951216      0.0        1.399556e-09     12.272360  4.466746e+01
12       1485.013794              0.178  1.950762      0.0        1.381967e-09     12.114989  4.465584e+01
13       1506.648315              0.178  1.942643      0.0        1.100982e-09     11.167084  4.475331e+01
14       1580.780029              0.178  1.928508      0.0        7.387948e-10      9.350249  4.485334e+01
15       1832.828735              0.178  1.901971      0.0        3.453772e-10      6.842797  4.508751e+01
16       2604.075684              0.178  1.869294      0.0        1.325485e-10      4.191604  4.518609e+01
17       4594.301270              0.178  1.844949      0.0        6.390201e-11      1.771347  4.435276e+01
18       6976.270996              0.178  1.829467      0.0        3.987927e-11      0.409881  4.214808e+01
19       8000.000000              0.178  1.821491      0.0        3.120619e-11      0.000000  6.300214e-15
20       8000.000000              0.178  1.813868      0.0        2.464867e-11      0.000000  1.064796e-14
21       8000.000000              0.178  1.809796      0.0        2.171752e-11      0.000000  5.615234e-16
22       8000.000000              0.178  1.808778      0.0        2.103918e-11      0.000000  3.825272e-16
23       8000.000000              0.178  1.806231      0.0        1.943143e-11      0.000000  5.712599e-15
```

[data.csv](https://github.com/pvlib/pvlib-python/files/11807543/data.csv)


> If we have one negative number in a large timeseries, the simulation will crash which seems too strict.

Agree this is not desirable.

My thoughts:

1. We could insert `v_oc = np.maximum(v_oc, 0)` above this [line](https://github.com/pvlib/pvlib-python/blob/e643dc3f835c29b12b13d7375e33885dcb5d07c7/pvlib/singlediode.py#L649). That would preserve nan.
2. I am reluctant to change `_lambertw_v_from_i`. That function's job is to solve the diode equation, which is valid for negative current. I don't think this function should make decisions about its solution. There will always be some degree of imprecision (currently it's around 10-13 or smaller, I think).
3. I am also reluctant to change `_golden_sect_DataFrame` for similar reasons - the function's job should be to find a minimum using the golden section search. Complying with the `lower < upper` requirement is the job of the code that calls this function.


1/ makes sense to me. I agree with the CONS for 2/ and 3/

Happy to open a PR with 1. if that helps. 
> Happy to open a PR with 1. if that helps.

That is welcome.  Because I'm cautious about junk values with larger magnitude being covered up by 0s, maybe 

```
v_oc[(v_oc < 0) & (v_oc > 1e-12)] = 0.
```


That's unexpected, thanks for reporting. 

I'll note that the negative Voc results from taking the difference of two very large but nearly equal numbers. It's likely limited to the CEC model, where the shunt resistance is inversely proportional to irradiance, which would be about 1e19 at photocurrent of 1e-17 for this case.
Now this gets strange: the Voc value is positive with pvlib v0.9.3. The function involved `pvlib.singlediode._lambertw_v_from_i` hasn't changed for many releases. In both pvlib v0.9.3 and v0.9.4, in this calculation of Voc, the lambertw term overflows so the Voc value is computed using only python arithmetic operators and numpy.log.

I'm starting to think the error depends on python and numpy versions.
The difference between 0.9.3 and 0.9.4 here may be due to slightly different values returned by `calcparams_cec`.  Compare the output of `print(list(map(str, params)))`; I get slightly different saturation current values for the given example.  Maybe the changed Boltzmann constant in #1617 is the cause?
+1 to #1617 as the likely culprit. I get the positive/negative Voc values with the same python and numpy versions but different pvlib versions.
To illustrate the challenge, [this line](https://github.com/pvlib/pvlib-python/blob/f4d7c6e1c17b3fddba7cc49d39feed2a6fa0f30e/pvlib/singlediode.py#L566) computes the Voc.

Stripping out the indexing the computation is

```
    V = (IL + I0 - I) / Gsh - \
        I * Rs - a * lambertwterm
```
With pvlib v0.9.4, Io is 7.145289906185543e-12. a is not affected, since a value of the Boltzmann contant is inherent in the a_ref value from the database. (IL + I0 - I) / Gsh is 107825185636.40567, I * Rs is 0, and a * lambertwterm is 107825185636.40569

With pvlib v0.9.3, Io is 7.145288699667595e-12.  (IL + I0 - I) / Gsh is 107825167429.58397, I * Rs is 0, and a * lambertwterm is 107825167429.58395

The difference defining Voc is in the least significant digit.

Increasing the iterations that solve for lambertwterm doesn't fix this issue.
This smells to me like the inevitable error from accumulated round-off. 

FWIW, negative Voc can be achieved in 0.9.3 as well -- try the given example but with `effective_irradiance=1.e-18`.  The difference is that before #1606, it led to nans and warnings instead of raising an error. 


@pasquierjb I recommend intercepting the effective irradiance and setting values to 0 which are below a minimum on the order of 1e-9 W/m2. That will propagate to shunt resistance = np.inf, which changes the calculation path in pvlib.singlediode and gives Voc=0.

I'm not sure we'll be able to extend the numerical solution of the single diode equation to be accurate at very low but non-zero values of photocurrent (and/or enormous but finite values of shunt resistance.)

I note that `pvlib.pvsystem.calcparams_desoto` doesn't like `effective_irradiance=0.` but is OK with `effective_irradiance=np.array([0.])`.  Has to do with trapping and ignoring division by zero warnings and errors.
Have you tried setting `method='newton'` instead of `'lambertw'`? https://pvlib-python.readthedocs.io/en/stable/reference/generated/pvlib.pvsystem.singlediode.html#pvlib-pvsystem-singlediode
Setting `method='newton'` gets a solution to this case. `method` isn't available as a parameter of the `PVSystem.singlediode` method so @pasquierjb would need to change his workflow to use it. Something for us to consider adding.
My workaround for this issue was to first filter very low `effective_irradiance` values (`<1e-8`), and then filter `photocurrent` and `saturation_current` parameters when `effective_irradiance=0` and made them `=0`. This assures that you won't get negative `v_oc` values.
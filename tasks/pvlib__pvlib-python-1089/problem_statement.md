Apparent numerical instability in I_mp calculation using PVsyst model
**Describe the bug**

I used these parameters in `pvlib.pvsystem.calcparams_pvsyst()` in order to calculate `I_mp` vs. `T` using `pvlib.pvsystem.singlediode()` with `effective_irradiance` fixed at 1000 W/m^2 and `temp_cell` having 1001 values ranging from 15 to 50 degC:

`{'alpha_sc': 0.006, 'gamma_ref': 1.009, 'mu_gamma': -0.0005, 'I_L_ref': 13.429, 'I_o_ref': 3.719506010004821e-11, 'R_sh_ref': 800.0, 'R_sh_0': 3200.0, 'R_s': 0.187, 'cells_in_series': 72, 'R_sh_exp': 5.5, 'EgRef': 1.121, 'irrad_ref': 1000, 'temp_ref': 25}`

My purpose was to investigate the temperature coefficient of `I_mp`, and I got the following result, which appears to suffer from a numeric instability:

![image](https://user-images.githubusercontent.com/1125363/98264917-ab2d2880-1f45-11eb-83a2-e146774abf44.png)

For comparison, the corresponding `V_mp` vs. `T` plot:

![image](https://user-images.githubusercontent.com/1125363/98264984-bc763500-1f45-11eb-9012-7c29efa25e1e.png)

**To Reproduce**

Run the above calculations using the parameters provided.

**Expected behavior**

Better numerical stability in `I_mp` vs. `T`.

**Screenshots**

See above.

**Versions:**

 - ``pvlib.__version__``: 0.8.0
 - ``numpy.__version__``: 1.19.2
 - ``scipy.__version__``: 1.5.2
 - ``pandas.__version__``: 1.1.3
 - python: 3.8.5

**Additional context**

I was going to attempt a numerical computation of the temperature coefficient of `I_mp` for a model translation to the SAPM. I have seen reports from CFV in which this coefficient is actually negative, and I have computed it alternately using the `P_mp` and `V_mp` temperature coefficients, and gotten a negative value for this particular PV module. Despite the apparent numerical instability in the above plot, it still suggests that the coefficient should be positive, not negative. Perhaps I am missing something here?

Also, I have not dug deep enough to figure out if the underlying issue is in `pvlib.pvsystem.singlediode()`.

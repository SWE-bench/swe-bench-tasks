The Perez diffuse model should not be forcing the horizon coefficient up to zero
The perez model in irradiance.py forces F2, and thus the horizon component of diffuse, to be non-negative.  This restriction should not happen.  F2 and the horizon coefficient should be allowed to be negative and to reduce overall diffuse.

According to the original paper at https://www.osti.gov/servlets/purl/7024029
Section III.2 states this explicitly for the horizon component:
"(2) The horizon brightening coefficient, F2, is negative for overcast and low E occurrences -- indicative of brightening of the zenithal region of the sky for these conditions. This becomes positive past intermediate conditions and increases substantially with clearness."

We observed a higher than expected POAI, coming from poa diffuse, on cloudy days at certain sites.
Expected:
Horizon (burgundy) can be less than zero and sky diffuse (green) is less than isotropic (blue)
![image](https://user-images.githubusercontent.com/81724637/119172295-9ebc7900-ba1a-11eb-8e1a-3a170e1f995a.png)

Observed from PVLib:
Horizon is prevented from being negative and sky diffuse ends up higher than isotropic.
![image](https://user-images.githubusercontent.com/81724637/119172410-c4498280-ba1a-11eb-8e91-540db0ddc609.png)

Repro'd on PVLib 0.8.1

See added test case in the PR for this repro case.


IAM that supports AR coating like Fresnel
# Problem
Currently pvlib supports the DeSoto physical model (similar to normal glass), ASHRAE, Martin & Ruiz, and SAPM polynomial, but it doesn't have a pure Fresnel model that allows additional interfaces like an AR coating. 

* DeSoto physical model is most similar to the Fresnel for normal glass but only has one interface, so is limited to IAM curves below it only, while an AR coating would have a greater &rho; 
* Martin & Ruiz could be used to approximate an AR coated glass if the correct `a_r` were known. The default of `a_r=0.16` is slightly above the normal glass Fresnel IAM, but an `a_r=0.14` seems to match an AR coating with index of refraction of 1.2 most closely.

![pvlib_iam](https://user-images.githubusercontent.com/1385621/180581071-0ff411f1-144a-40b6-a6a9-189ef55f019f.png)


# Proposal
a new method in `pvl.iam.fresnel_ar(aoi, n_ar=1.2, n_air=1.0, n_glass=1.56)` that implements the [Fresnel equation](https://en.wikipedia.org/wiki/Fresnel_equations)

# Alternative
Suggest readers to use Martin & Ruiz with `a_r=0.14` instead of default.

# additional content
PVsyst has switched to Fresnel equations. We can duplicate [their methods](https://www.pvsyst.com/help/iam_loss.htm) ignoring additional reflections and the encapsulant layer:
![Fresnel-v-ASHRAE](https://user-images.githubusercontent.com/1385621/180581112-67f3ed9d-5bd3-4dfe-8180-8b5d173fcdd2.png)

<details>

```python
import numpy as np
import matplotlib.pyplot as plt
plt.ion()


# constants
n_glass = 1.56
n_air = 1.0
theta_inc = np.linspace(0, 88, 100)


def snell(theta_1, n1, n2):
    """Snell's equation"""
    sintheta_2 = n1/n2 * np.sin(np.radians(theta_1))
    return sintheta_2, np.degrees(np.arcsin(sintheta_2))


def refl_s(theta_1, theta_2, n1, n2):
    """Fresnel's equation"""
    n1_costheta_1 = n1*np.cos(np.radians(theta_1))
    n2_costheta_2 = n2*np.cos(np.radians(theta_2))
    return np.abs((n1_costheta_1 - n2_costheta_2)/(n1_costheta_1 + n2_costheta_2))**2


def refl_p(theta_1, theta_2, n1, n2):
    """Fresnel's equation"""
    n1_costheta_2 = n1*np.cos(np.radians(theta_2))
    n2_costheta_1 = n2*np.cos(np.radians(theta_1))
    return np.abs((n1_costheta_2 - n2_costheta_1)/(n1_costheta_2 + n2_costheta_1))**2


def refl_eff(rs, rp):
    """effective reflectivity"""
    return (rs+rp)/2


def trans(refl):
    """transmissivity"""
    return 1-refl


def refl0(n1, n2):
    """reflectivity at normal incidence"""
    return np.abs((n1-n2)/(n1+n2))**2


def fresnel(theta_inc, n1=n_air, n2=n_glass):
    """calculate IAM using Fresnel's Law"""
    _, theta_tr = snell(theta_inc, n1, n2)
    rs = refl_s(theta_inc, theta_tr, n1, n2)
    rp = refl_p(theta_inc, theta_tr, n1, n2)
    reff = refl_eff(rs, rp)
    r0 = refl0(n1, n2)
    return trans(reff)/trans(r0)


def ashrae(theta_inc, b0=0.05):
    """ASHRAE equation"""
    return 1 - b0*(1/np.cos(np.radians(theta_inc)) - 1)


def fresnel_ar(theta_inc, n_ar, n1=n_air, n2=n_glass):
    """calculate IAM using Fresnel's law with AR"""
    # use fresnel() for n2=n_ar
    _, theta_ar = snell(theta_inc, n1, n_ar)
    rs_ar1 = refl_s(theta_inc, theta_ar, n1, n_ar)
    rp_ar1 = refl_p(theta_inc, theta_ar, n1, n_ar)
    r0_ar1 = refl0(n1, n_ar)
    # repeat with fresnel() with n1=n_ar
    _, theta_tr = snell(theta_ar, n_ar, n2)
    rs = refl_s(theta_ar, theta_tr, n_ar, n2)
    rp = refl_p(theta_ar, theta_tr, n_ar, n2)
    # note that combined reflectivity is product of transmissivity!
    # so... rho12 = 1 - (1-rho1)(1-rho2) 
    reff = refl_eff(1-(1-rs_ar1)*(1-rs), 1-(1-rp_ar1)*(1-rp))
    r0 = 1-(1-refl0(n_ar, n2))*(1-r0_ar1)
    return trans(reff)/trans(r0)


# plot Fresnel for normal glass and ASHRAE
plt.plot(theta_inc, fresnel(theta_inc))
plt.plot(theta_inc, ashrae(theta_inc))

# calculate IAM for AR with n=1.1 and plot
iam_ar11 = fresnel_ar(theta_inc, n_ar=1.1)
plt.plot(theta_inc, iam_ar11)

# repeat for AR with n=1.2
iam_ar12 = fresnel_ar(theta_inc, n_ar=1.2)
plt.plot(theta_inc, iam_ar12)

# make plot pretty
plt.legend(['Fresnel, normal glass', 'ASHRAE, $b_0=0.05$', 'Fresnel $n_{AR}=1.1$', 'Fresnel $n_{AR}=1.2$'])
plt.title("IAM correction, Fresnel vs. ASHRAE, using basic eqn's")
plt.ylabel('IAM')
plt.xlabel(r'incidence angle $\theta_{inc} [\degree]$')
plt.grid()
plt.ylim([0.55,1.05])
```
</details>



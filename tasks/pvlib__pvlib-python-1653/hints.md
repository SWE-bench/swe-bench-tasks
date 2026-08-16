Interestingly, clamping the difference of squares at 0.01 was part of the original PR but got lost along the way: https://github.com/pvlib/pvlib-python/pull/1251#discussion_r830258000

It would be great if the communication with the author results in improved tests as well as improved code.
After communications with the author, the pvlib code is missing two items:

- a lower bound on `lower_edge_height_clipped**2 - effective_snow_weighted_m**2` which the author specifies should be 0.1 in^2.
- a factor that multiplies the monthly loss fraction, to represent the potential for a string of modules at the top of the slanted array to generate power while strings at lower positions are still affected by snow.  This factor was brought up in #1625 

Neither is documented in the 2011 paper but should be added to 1) prevent unreasonably low loss values (item 1) and to better represent the loss for systems with multiple, horizontally-oriented strings.

Also, the author recommends advising users to enter 1/2 the total module width as the slant_height for single-axis tracked systems, which makes sense to me, as snow could slide off either surface depending on its rotation. 
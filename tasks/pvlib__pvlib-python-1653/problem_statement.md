Corrections to Townsend snow model
Private communications with the model's author have turned up some issues with the pvlib implementation. Chief among the issues is  this part of the calculation:

```
    lower_edge_height_clipped = np.maximum(lower_edge_height, 0.01)
    gamma = (
        slant_height
        * effective_snow_weighted_m
        * cosd(surface_tilt)
        / (lower_edge_height_clipped**2 - effective_snow_weighted_m**2)
        * 2
        * tand(angle_of_repose)
    )

    ground_interference_term = 1 - C2 * np.exp(-gamma)
```

When `lower_edge_height_clipped` < `effective_snow_weighted_m`, `gamma` < 0 and the `ground_interference_term` can become negative. In contrast, the author's intent is that C2 < `ground_interference_terms` < 1. The author recommends clipping the squared difference (lower bound being worked out but will be something like 0.01.).

Other issues appear to arise from the unit conversions. The published model uses inches for distance and snow depth. The pvlib code uses cm for snow depth (convenience for working with external snow data) and m for distances (for consistency with the rest of pvlib). After several steps, including the `ground_interference_term` calculation, the code converts from cm or m to inches to apply the final formula for loss (since the formula involves some coefficients determined by a regression). It would be easier to trace the pvlib code back to the paper if the internal unit conversions (from cm / m to inches) were done earlier.


Would be easily fixable by changing:

    res = coeffs.isel({degree_dim: max_deg}, drop=True) + zeros_like(coord)

to

    res = zeros_like(coord) + coeffs.isel({degree_dim: max_deg}, drop=True)

At least until broadcasting rules don't change.
The old behavior is closer to numpy, so I guess worth fixing.
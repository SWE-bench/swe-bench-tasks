Match `pvsystem.i_from_v`, `v_from_i` single diode parameters with `singlediode` order.
**Is your feature request related to a problem? Please describe.**
The single diode model parameters for `i_from_v`, `v_from_i` in `pvsystem` are expected in a different order than `pvsystem.singlediode`.
This makes it difficult to pass the parameters to all of these functions using `*args`.

**Describe the solution you'd like**
Group and reorder the single diode parameters of `i_from_v`, `v_from_i` to match the order of `singlediode`.


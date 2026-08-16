Infinite sheds perf improvement: vectorize over surface_tilt
Infinite sheds is quite a bit slower than the modelchain POA modeling we use for frontside (as expected). I see a TODO comment in the code for _vf_ground_sky_integ (`_TODO: vectorize over surface_tilt_`) that could potentially result in some perf improvement for Infinite sheds calls with tracking systems.

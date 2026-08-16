Inconsistent default settings for _prep_inputs_solar_pos in prepare_inputs and prepare_inputs_from_poa
Hi there,

I find that `_prep_inputs_solar_pos` method has been both called in [`prepare_inputs`](https://pvlib-python.readthedocs.io/en/stable/_modules/pvlib/modelchain.html#ModelChain.prepare_inputs) and [`prepare_inputs_from_poa`](https://pvlib-python.readthedocs.io/en/stable/_modules/pvlib/modelchain.html#ModelChain.prepare_inputs_from_poa). However, the former takes an additional argument, press_temp that contains temperature pulled from the weather data provided outside. For the default `nrel_numpy` algorithm, I further checked its input requirement is [avg. yearly air temperature in degrees C](https://pvlib-python.readthedocs.io/en/stable/generated/pvlib.solarposition.spa_python.html#pvlib.solarposition.spa_python) rather than the instantaneous temperature provided in weather. Hence I would like to ask if the following codes in `prepare_inputs` are redundant at least for the default 'nrel_numpy' algorithm?
```
        # build kwargs for solar position calculation
        try:
            press_temp = _build_kwargs(['pressure', 'temp_air'], weather)
            press_temp['temperature'] = press_temp.pop('temp_air')
        except KeyError:
            pass
```
And thereby we change `self._prep_inputs_solar_pos(press_temp)` to `self._prep_inputs_solar_pos()` in `prepare_inputs`?

Meanwhile, does the temperature really matter? How much uncertainty will it cause in the calculation of the sun's position? Should we provide avg. local temperature data if for a global modelling purpose?

Any help would be appreciated!



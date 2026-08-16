> Meanwhile, does the temperature really matter? How much uncertainty will it cause in the calculation of the sun's position? Should we provide avg. local temperature data if for a global modelling purpose?

Taking [A simple ModelChain example](https://pvlib-python.readthedocs.io/en/stable/modelchain.html#a-simple-modelchain-example) as an illustration, I find the difference caused by temperature argument is very small:

`mc.solar_position` produced in the tutorial above:
![image](https://user-images.githubusercontent.com/43779303/94040505-f2f65700-fdc0-11ea-84f9-bbf842c76fb4.png)

with default temperature=12 `mc.location.get_solarposition(mc.weather.index, method=mc.solar_position_method)`:
![image](https://user-images.githubusercontent.com/43779303/94040659-1de0ab00-fdc1-11ea-936c-fdca38d8e47f.png)

Only slight difference in apparent_zenith and thereby apparent_elevation come in being.

That said, I would still think we'd better not to use instantaneous temp_air pulled from weather provided outside to calculate solar position? Besides this [documentation](https://pvlib-python.readthedocs.io/en/stable/generated/pvlib.solarposition.spa_python.html#pvlib.solarposition.spa_python), I find the [original paper](https://www.sciencedirect.com/science/article/pii/S0038092X0300450X) also states annual local temperature.

Any discussion would be appreciated!

Thanks @FeiYao-Edinburgh. 

The two `_prep` functions should certainly be consistent. 

I agree that the documentation and original paper state that the appropriate quantity is the average yearly temperature. I don't know why we accepted #936/#893/#523 without discussing this.

I'm disinclined to expose the average temperature or pressure through `ModelChain` - it would be an awkward API for no practical benefit.
> I'm disinclined to expose the average temperature or pressure through `ModelChain` - it would be an awkward API for no practical benefit.

I think so, too. This is simply because avg. yearly temperature or pressure is somewhat a time-invariant variable. Thus if it is pulled from weather data outside, it will cause weather data somewhat redundant containing many repeated values throughout time.

Alternatively, maybe we can add `temperature` as a new attribute to [Location](https://pvlib-python.readthedocs.io/en/stable/generated/pvlib.location.Location.html) class. Then we can treat temperature as what we do for altitude. More specifically:

1. Make changes outlined in my initial comment.
2. In [Location.get_solarposition](https://pvlib-python.readthedocs.io/en/stable/_modules/pvlib/location.html#Location.get_solarposition), remove temperature argument:
```
    def get_solarposition(self, times, pressure=None,
                          **kwargs):
```
and use self.temperature instead:
```
        return solarposition.get_solarposition(times, latitude=self.latitude,
                                               longitude=self.longitude,
                                               altitude=self.altitude,
                                               pressure=pressure,
                                               temperature=self.temperature,
                                               **kwargs)
```
Then in [pvlib.solarposition.get_solarposition](https://pvlib-python.readthedocs.io/en/stable/_modules/pvlib/solarposition.html#get_solarposition), make the default temperature as None:
```
def get_solarposition(time, latitude, longitude,
                      altitude=None, pressure=None,
                      method='nrel_numpy',
                      temperature=None, **kwargs):
```
and determine if temperature is None or not just like we do for altitude/pressure:
```
if temperature is None:
    temperature=12
# Otherwise use the self.temperature
```
I am not sure whether this small issue is important enough to re-structure the Location class but happy to discuss.


I exchanged email with Ibrahim Reda, the author of the SPA algorithm. His point is that refraction is being corrected by the atmospheric content between the observer and the sun, which cannot be known. They chose to use annual average temperature and pressure (rather than moment in time air temperature and pressure near earth's surface) by consensus, because the refraction correction is small (in terms of sun position), and either temperature gets the refraction close enough. I also suspect that annual data was easier to obtain.

IMO using the time-dependent air temperature is justified in pvlib, but it is a departure from the SPA algorithm as published. 

I see two options:

1. leave the calculation as is, change docstrings and add comment about the variation from the SPA publication. Users can still supply annual average temperature as `temp_air` if they want to strictly adhere to the publication.
2. find and include global grids of average annual temperature and pressure, and wire these data into the SPA algorithm in the same way that the Linke turbidity data serve the Ineichen function.

I favor the first.

@adriesse would this have affected the comparisons you did a few years back between various PV-related software?

> 1. leave the calculation as is, change docstrings and add comment about the variation from the SPA publication. Users can still supply annual average temperature as `temp_air` if they want to strictly adhere to the publication.

For this, I think it might be good to make the following changes in [`prepare_inputs_from_poa`](https://pvlib-python.readthedocs.io/en/stable/_modules/pvlib/modelchain.html#ModelChain.prepare_inputs_from_poa) to enable consistent calculations.
```
self._prep_inputs_solar_pos()
```
to
```
        # build kwargs for solar position calculation
        try:
            press_temp = _build_kwargs(['pressure', 'temp_air'], self.weather) # weather => self.weather (TBC)
            press_temp['temperature'] = press_temp.pop('temp_air')
        except KeyError:
            pass
        self._prep_inputs_solar_pos(kwargs=press_temp)
```
Thanks for checking on this @cwhanse.

The `solarposition.spa_python` temperature/pressure documentation is clear and consistent with the reference, so I think we should leave it alone. We should double check the expectations for the other algorithms and update their documentation if needed. The `solarposition.get_solarposition` documentation will need to be updated. 

Users are free to obtain their own average annual temperature and pressure data and provide them to `spa_python`. I'm -1 on distributing gridded average temperature/pressure data with pvlib. I suspect the altitude pressure conversion that we already support is plenty accurate for this purpose, so users only need to find their own temperature if they care that much about it.

When it comes to ModelChain, I'm ok with consistently using the temperature time series or removing the correction entirely. @FeiYao-Edinburgh's idea of a `Location.average_temperature` attribute is interesting, but I think I'd want to see more applications of this attribute before considering it worth the API complication.
I agree that the `prepare_inputs` methods should be consistent whichever course we take on using air temperature for solar position calculations.
@cwhanse thanks for inviting me to this discussion.

Earlier this year or last I read the Wikipedia article about atmospheric refraction (highly recommended), did some refraction calculations myself, and started to wonder about the point of SPA.  The effect of refraction is huge compared to "SPA is well within the stated uncertainty of ± 0.0003 deg."   

It is nice for pvlib to provide SPA code corresponding to its published form, but for PV simulations consistency is much more useful than super high accuracy.  Using fixed values for temperature and pressure promotes consistency.

If it were my code I would separate the sun position and refraction code because they model entirely different things.

Why not implement or use [solpos](https://www.nrel.gov/grid/solar-resource/solpos.html) instead. It's much simpler and faster than spa, includes refraction, and is accurate enough considering uncertainty in irradiance & other parameters. Also it solves @kanderso-nrel  issue with implementing spectr2
Might be worth synchronizing with SAM at least on the default for the sun position calculation. 

It looks like [SAM ](https://github.com/NREL/ssc/blob/c6e41d7d946723e3cc4111262abcab081c151621/solarpilot/solpos.cpp) uses that solpos C function. For the refraction calculation (which appears to be different than in SPA) pressure and temperature can be time-dependent, or fixed at defaults (1013mb and 15C, the docstring says 10C but that looks to be a typo).

I don't have a preference for any of the solar position algorithms. A drawback of SOLPOS is that it does not appear to be published other than as code.
I had this document in my archives, but it similar to what's already online
[SOLPOS Documentation.pdf](https://github.com/pvlib/pvlib-python/files/5290012/SOLPOS.Documentation.pdf)

More background to my earlier comment:

Last year I compared simulation output from SAM, PlantPredict, Cassys, PVsyst and pvlib.  This was made more difficult because _four_ different sun position algorithms were being used, and this is why I advocated for harmonization.  I recommended SPA because I thought it more likely that others would switch to that, as opposed to the other way around.  So perhaps we could make a pitch to SAM to adopt SPA instead.  But we also need consistency on refraction.


> I had this document in my archives, but it similar to what's already online

Yes. I was hoping for something to cite besides the webpage, if we implement SOLPOS.

I have no qualms about adding SOLPOS with only a citation to a webpage. It sounds like it could be a more standard and better documented version of the [`ephemeris`](https://github.com/pvlib/pvlib-python/blob/04a523fafbd61bc2e49420963b84ed8e2bd1b3cf/pvlib/solarposition.py#L683) function. We have a robust set of solar position tests and so it should be easy to have confidence in its results. 
Looks to me like Michalsky 1988 is the one to cite.
Looks like SAM is changing to SPA? https://github.com/NREL/ssc/pull/450
Great, perhaps we can get the same default behavior for refraction too... 
> Looks like SAM is changing to SPA? [NREL/ssc#450](https://github.com/NREL/ssc/pull/450)

SAM has (in it's [development branch)](https://github.com/NREL/ssc/pull/450#event-3921449470), using time-dependent temperature rather than annual average.
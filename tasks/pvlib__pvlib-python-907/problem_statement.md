access private _parse_pvgis_tmy_csv() function as read_pvgis_tmy_csv()
**Is your feature request related to a problem? Please describe.**
someone sent me a csv file they downloaded from pvgis, and I needed to parse it, so I had to call the private methods like this:

```python
>>> from pvlib.iotools.pvgis import _parse_pvgis_tmy_csv
>>> with (path_to_folder / 'pvgis_tmy_lat_lon_years.csv').open('rb') as f:
        pvgis_data = _parse_pvgis_tmy_csv(f)
```

**Describe the solution you'd like**
If I need this, others may also. I think a public method that takes either a string or a buffer could be useful? Something called `read_pvgis_tmy_csv()`

**Describe alternatives you've considered**
I was able to do it by just calling the private function and it worked, so that's an alternative also

**Additional context**
related to #845 and #849 

access private _parse_pvgis_tmy_csv() function as read_pvgis_tmy_csv()
**Is your feature request related to a problem? Please describe.**
someone sent me a csv file they downloaded from pvgis, and I needed to parse it, so I had to call the private methods like this:

```python
>>> from pvlib.iotools.pvgis import _parse_pvgis_tmy_csv
>>> with (path_to_folder / 'pvgis_tmy_lat_lon_years.csv').open('rb') as f:
        pvgis_data = _parse_pvgis_tmy_csv(f)
```

**Describe the solution you'd like**
If I need this, others may also. I think a public method that takes either a string or a buffer could be useful? Something called `read_pvgis_tmy_csv()`

**Describe alternatives you've considered**
I was able to do it by just calling the private function and it worked, so that's an alternative also

**Additional context**
related to #845 and #849 


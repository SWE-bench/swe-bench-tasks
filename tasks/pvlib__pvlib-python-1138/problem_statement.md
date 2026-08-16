document or support modules_per_string strings_per_inverter with pvwatts in modelchain
Hi, 

I am trying to run Modelchain with pvwatt model but it seems that the `modules_per_string` and `strings_per inverter ` doesn't have any affect on the total output. 

I am not sure why is it so. 
May be ModelChain isn't supporting so. If that's the case how can I achieve the desired result?

Here is my code: 

Thanks in advance
```
# built-in python modules
import os
import inspect

# scientific python add-ons
import numpy as np
import pandas as pd

# plotting stuff
# first line makes the plots appear in the notebook
%matplotlib inline 
import matplotlib.pyplot as plt
import matplotlib as mpl
# seaborn makes your plots look better
try:
    import seaborn as sns
    sns.set(rc={"figure.figsize": (12, 6)})
    sns.set_color_codes()
except ImportError:
    print('We suggest you install seaborn using conda or pip and rerun this cell')

# finally, we import the pvlib library
import pvlib

tmy = pd.read_csv("http://re.jrc.ec.europa.eu/pvgis5/tmy.php?lat=29.74&lon=40.10")

tmy.Date = pd.to_datetime(tmy.Date, format='%Y-%d-%m %H:%M:%S')

tmy.rename(columns={' Ghor':'ghi','Dhor':'dhi','DNI':'dni','Tair':'temp_air',
                        'Ws':'wind_speed'},inplace=True)					
						
tmy.set_index(tmy['Date'],inplace=True)
    #Drop unnecessary column

tmy = tmy.drop('Date', 1)
tmy = tmy.drop('RH', 1)
tmy = tmy.drop('IR', 1)
tmy = tmy.drop(' Wd', 1)
tmy = tmy.drop('Pres', 1)

#module =Jinko_Solar_JKM320P_72_V
#inverter = ABB__PVS980_58_2000kVA_K__N_A_V__CEC_2018_

lat = 29.74
lon = 40.10
altitude = 676
tz = 'Etc/GMT+3'  

loc = pvlib.location.Location(latitude=lat,longitude= lon,tz=tz)

#model = pvwatts 
pvwatts_system = pvlib.pvsystem.PVSystem(module_parameters={'pdc0': 320, 'gamma_pdc': -0.0041},inverter_parameters={'pdc' : 3200000, 'pdc0' : 2024292, 'eta_inv_nom':0.988, 'eta_inv_ref':0.986},surface_tilt = 20, surface_azimuth=0,
                    modules_per_string=30,strings_per_inverter=267, albedo = 0.2)
					
mc = pvlib.modelchain.ModelChain(pvwatts_system, loc, transposition_model ="perez",aoi_model = 'ashrae',spectral_model='no_loss')
print(mc)
mc.run_model(times=tmy.index,weather=tmy)
a = mc.ac
a = pd.Series.to_frame(a)
a = a * 530  # 530 = number of inverters in the system 

a['month'] = a.index
a.month = a.month.dt.month
monthly = a.groupby('month').sum()
```



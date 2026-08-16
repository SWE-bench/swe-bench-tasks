Add a model for spectral corrections
**Additional context**
First of all, I introduce myself, my name is Jose Antonio Caballero, and I have recently finished my PhD in photovoltaic engineering at the University of Jaén, Spain.

I have developed a python script to apply spectral corrections as a function of AM, AOD, PW based on this work (https://doi.org/10.1109/jphotov.2017.2787019).

We have found that in pvlib there is already a similar methodology developed by First solar, in which the spectral corrections are based only on the AM and PW parameters, so we intend to include our proposed method in pvlib in a similar way.

As an example, I attach the code developed in python (.zip file) to estimate the spectral effects related to different flat photovoltaic technologies from the AM, AOD and PW parameters included in a .csv file.
[PV-MM-AM_AOD_PW_data.csv](https://github.com/pvlib/pvlib-python/files/6970716/PV-MM-AM_AOD_PW_data.csv)
[PV_Spectral_Corrections.zip](https://github.com/pvlib/pvlib-python/files/6970727/PV_Spectral_Corrections.zip)

Kind regards

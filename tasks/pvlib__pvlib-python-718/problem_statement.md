CEC 6-parameter coefficient generation
SAM is able to extract the CEC parameters required for calcparams_desoto.  This is done through the 'CEC Performance Model with User Entered Specifications' module model, and coefficients are automatically extracted given nameplate parameters Voc, Isc, Imp, Vmp and TempCoeff.  The method is based on Aron Dobos' "An Improved Coefficient Calculator for the California Energy Commission 6 Parameter Photovoltaic Module Model ", 2012

Ideally we should be able to work with the SAM open source code, extract the bit that does the coefficient generation, and put it into a PVLib function that would allow users to run calcparams_desoto with any arbitrary module type.  At the moment we are dependent on PV modules loaded into the SAM or CEC database.

Thank you!


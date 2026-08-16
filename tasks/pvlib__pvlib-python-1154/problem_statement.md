pvlib.irradiance.reindl() model generates NaNs when GHI = 0
**Describe the bug**
The reindl function should give zero sky diffuse when GHI is zero. Instead it generates NaN or Inf values due to "term3" having a quotient that divides by GHI.  

**Expected behavior**
The reindl function should result in zero sky diffuse when GHI is zero.


pvlib.irradiance.reindl() model generates NaNs when GHI = 0
**Describe the bug**
The reindl function should give zero sky diffuse when GHI is zero. Instead it generates NaN or Inf values due to "term3" having a quotient that divides by GHI.  

**Expected behavior**
The reindl function should result in zero sky diffuse when GHI is zero.



make read_crn accomodate bad files
A couple of issues with our `read_crn` function. 

First, the character sequence '\x00\x00\x00\x00\x00\x00' occasionally shows up and trips up pandas. This can be fixed by adding `na_values=['\x00\x00\x00\x00\x00\x00']` to the reader.

Second, we try to set the `CRX_VN` column to dtype int, but it occasionally has floats that cannot be coerced. The [documentation](https://www1.ncdc.noaa.gov/pub/data/uscrn/products/subhourly01/README.txt) says it should be treated like a string.

Example below shows both issues in `'CRNS0101-05-2020-FL_Titusville_7_E.txt'`

```
92821 20200706 1145 20200706 0645      3  -80.69   28.62    24.5     0.0    151 0    24.7 C 0    94 0 -99.000 -9999.0   990 0   1.23 0
92821 20200706 1150 20200706 0650      3  -80.69   28.62    24.7     0.0    168 0    25.0 C 0    94 0 -99.000 -9999.0   990 0   1.28 0
92821 20200706 1155 20200706 0655      3  -80.69   28.62    24.9     0.0    173 0    25.3 C 0    93 0 -99.000 -9999.0   990 0   1.48 0
92821 20200706 1200 20200706 0700      3  -80.69   28.62    24.9     0.0    190 0    25.5 C 0    93 0 -99.000 -9999.0   990 0   1.57 0
\x00\x00\x00\x00\x00\x00 repeated
92821 20200706 1305 20200706 0805  2.623  -80.69   28.62    26.8     0.0    409 0    30.0 C 0    87 0 -99.000 -9999.0   988 0   1.44 0
92821 20200706 1310 20200706 0810  2.623  -80.69   28.62    26.9     0.0    430 0    30.2 C 0    87 0 -99.000 -9999.0   989 0   1.64 0
92821 20200706 1315 20200706 0815  2.623  -80.69   28.62    27.0     0.0    445 0    30.4 C 0    86 0 -99.000 -9999.0   989 0   1.94 0
92821 20200706 1320 20200706 0820  2.623  -80.69   28.62    27.3     0.0    463 0    30.8 C 0    86 0 -99.000 -9999.0   988 0   1.50 0
92821 20200706 1325 20200706 0825  2.623  -80.69   28.62    27.6     0.0    478 0    31.1 C 0    85 0 -99.000 -9999.0   988 0   1.54 0
92821 20200706 1330 20200706 0830  2.623  -80.69   28.62    27.6     0.0    496 0    31.5 C 0    84 0 -99.000 -9999.0   988 0   1.48 0
```

fyi @lboeman 

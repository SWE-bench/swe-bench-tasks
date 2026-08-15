Thanks for the thorough report. It seems to be casting to integer dtype here:
https://github.com/scikit-learn/scikit-learn/blob/88846b3be23e96553fb90d0c5575d74ffd8dbff2/sklearn/metrics/pairwise.py#L1191

I think instead it should be using the dtype of the return values, or else something like `_return_float_dtype`. https://github.com/scikit-learn/scikit-learn/blob/88846b3be23e96553fb90d0c5575d74ffd8dbff2/sklearn/metrics/pairwise.py#L37-L58

A pull request adding a test and fixing this is very welcome.
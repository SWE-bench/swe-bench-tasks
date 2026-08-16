Pickling/unpickling timezone in DT does not work
**Describe the bug**

The following tests fail because the timezone is not set in the unpickled `DT`:
```py
    def test_pickling_with_timezone():
        dt = pydicom.valuerep.DT("19111213212123-0630")
        loaded_dt = pickle.loads(pickle.dumps(dt))
        assert dt == loaded_dt

    def test_pickling_dt_from_datetime_with_timezone():
        tz_info = timezone(timedelta(seconds=-23400), '-0630')
        dt_object = datetime(2022, 12, 31, 23, 59, 59, 42, tzinfo=tz_info)
        dt = pydicom.valuerep.DT(dt_object)
        loaded_dt = pickle.loads(pickle.dumps(dt))
        assert dt == loaded_dt
```

This is a spin-off of PR #1365, see [this comment](https://github.com/pydicom/pydicom/pull/1365#issuecomment-829544827).

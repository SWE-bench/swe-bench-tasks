Thanks for working on this important issue!

There are a lot of edge cases that can come up in `concat`, so I think it would be very helpful to try to enumerate a broader set of unit tests for thoroughly testing this. For example:
- Pre-existing vs non-pre-existing dimension
- Pre-existing dimensions of different sizes
- Missing data variables vs coordinates vs indexed coordinates
Ok, I'll work on extending the updates with the feedback and additional tests.  Thanks!
Hi, I've provided a new update to this PR (sorry it took me awhile both to get more familiar with the code and find the time to update the PR).  I improved the logic to be a bit more performant and handle more edge cases as well as updated the test suite.  I have a few questions:

1. The tests I wrote are a bit more verbose than the tests previously.  I can tighten them down but I found it was easier for me to read the logic in this form.  Please let me know what you prefer.
2. I'm still not quite sure I've captured all the scenarios as I'm a pretty basic xarray user so please let me know if there is still something I'm missing.

I'll take a look at this more carefully soon. But I do think it is a hard
requirement that concat runs in linear time (with respect to the total
number of variables across all datasets).

On Mon, Dec 30, 2019 at 5:18 PM Scott Chamberlin <notifications@github.com>
wrote:

> Hi, I've provided a new update to this PR (sorry it took me awhile both to
> get more familiar with the code and find the time to update the PR). I
> improved the logic to be a bit more performant and handle more edge cases
> as well as updated the test suite. I have a few questions:
>
>    1. The tests I wrote are a bit more verbose than the tests previously.
>    I can tighten them down but I found it was easier for me to read the logic
>    in this form. Please let me know what you prefer.
>    2. I'm still not quite sure I've captured all the scenarios as I'm a
>    pretty basic xarray user so please let me know if there is still something
>    I'm missing.
>
> —
> You are receiving this because you were mentioned.
> Reply to this email directly, view it on GitHub
> <https://github.com/pydata/xarray/pull/3545?email_source=notifications&email_token=AAJJFVVSKN5ZWD4FQHPIJG3Q3KMWXA5CNFSM4JOLVICKYY3PNVWWK3TUL52HS4DFVREXG43VMVBW63LNMVXHJKTDN5WW2ZLOORPWSZGOEH3RY5Q#issuecomment-569842806>,
> or unsubscribe
> <https://github.com/notifications/unsubscribe-auth/AAJJFVUPKZ7Q3UFVSH7D2STQ3KMWXANCNFSM4JOLVICA>
> .
>

@scottcha If found this while searching. Have the same requirements, means missing DataArrays in some Datasets of a timeseries to be concatenated. I've already some hacks and workarounds in place for my specific use cases, but it would be really great if this could be handled by xarray.

I'll try to test your current implementation against my source data and will report my findings here. 

Update: I've rebased locally on latest master and this works smoothly with my data (which uses packed data). I'll now look into performance.
@scottcha @shoyer For one of my use cases (240 datasets, 1 with missing variables) I do not see any performance penalties using this implementation compared to the current. But this might be due to the fact, that the most time consuming part is the `expand_dims` for every dataset, which accounts for roughly 80% overall concat runtime.

If I can be of any help to push this over the line, please ping me.
>  the most time consuming part is the expand_dims for every dataset, which accounts for roughly 80% overall concat runtime.

Hmmm... maybe we need a short-circuit version of `expand_dims`?
@dcherian Just to clarify, the concatenation is done along a new dimension (which has to be created by expand_dims). What do you mean by short-clrcuit in this context? 
@kmuehlbauer @dcherian @shoyer  If it would be easier it could abandon this PR and resubmit a new one as the code has drastically changed since the original comments were provided?  Essentially I'm waiting for feedback or approval of this PR.
Can you explain why you think you need the nested iteration over dataset variables? What ordering are you trying to achieve?
@scottcha @shoyer below is a minimal example where one variable is missing in each file.

```python
import random
random.seed(123)
random.randint(0, 10)

# create var names list with one missing value
orig = [f'd{i:02}' for i in range(10)]
datasets = []
for i in range(1, 9):
    l1 = orig.copy()
    l1.remove(f'd{i:02}')
    datasets.append(l1)

# create files
for i, dsl in enumerate(datasets):
    foo_data = np.arange(24).reshape(2, 3, 4)
    with nc.Dataset(f'test{i:02}.nc', 'w') as ds:
        ds.createDimension('x', size=2)
        ds.createDimension('y', size=3)
        ds.createDimension('z', size=4)
        for k in dsl:
            ds.createVariable(k, int, ('x', 'y', 'z'))
            ds.variables[k][:] = foo_data

flist = glob.glob('test*.nc')
dslist = []
for f in flist:
    dslist.append(xr.open_dataset(f))

ds2 = xr.concat(dslist, dim='time')
ds2
```
Output: 

```
<xarray.Dataset>
Dimensions:  (time: 8, x: 2, y: 3, z: 4)
Dimensions without coordinates: time, x, y, z
Data variables:
    d01      (x, y, z) int64 0 1 2 3 4 5 6 7 8 9 ... 15 16 17 18 19 20 21 22 23
    d00      (time, x, y, z) int64 0 1 2 3 4 5 6 7 8 ... 16 17 18 19 20 21 22 23
    d02      (time, x, y, z) float64 0.0 1.0 2.0 3.0 4.0 ... 20.0 21.0 22.0 23.0
    d03      (time, x, y, z) float64 0.0 1.0 2.0 3.0 4.0 ... 20.0 21.0 22.0 23.0
    d04      (time, x, y, z) float64 0.0 1.0 2.0 3.0 4.0 ... 20.0 21.0 22.0 23.0
    d05      (time, x, y, z) float64 0.0 1.0 2.0 3.0 4.0 ... 20.0 21.0 22.0 23.0
    d06      (time, x, y, z) float64 0.0 1.0 2.0 3.0 4.0 ... 20.0 21.0 22.0 23.0
    d07      (time, x, y, z) float64 0.0 1.0 2.0 3.0 4.0 ... 20.0 21.0 22.0 23.0
    d08      (time, x, y, z) float64 0.0 1.0 2.0 3.0 4.0 ... nan nan nan nan nan
    d09      (time, x, y, z) int64 0 1 2 3 4 5 6 7 8 ... 16 17 18 19 20 21 22 23
```

Three cases here:

- `d00` and `d09` are available in all datasets, and they are concatenated correctly (keeping dtype)
- `d02` to `d08` are missing in one dataset and are filled with the created dummy variable, but the dtype is converted to float64
- `d01` is not handled properly, because it is missing in the first dataset, this is due to checking only variables of first dataset in [`_calc_concat_over`](https://github.com/scottcha/xarray/blob/cf5b8bdfb0fdaf626ecf7b83590f15aa9aef1d6b/xarray/core/concat.py#L235)

```python
            elif opt == "all":
                concat_over.update(
                    set(getattr(datasets[0], subset)) - set(datasets[0].dims)
                )
```
and from putting `d01` in [`result_vars`](https://github.com/scottcha/xarray/blob/cf5b8bdfb0fdaf626ecf7b83590f15aa9aef1d6b/xarray/core/concat.py#L329) before iterating to find missing variables.


I am now wondering if we can use `align` or `reindex` to do the filling for us.

Example: goal is concat along 'x' with result dataset having `x=[1,2,3,4]`
1. Loop through datasets and assign coordinate values as appropriate. 
2. Break datasets up into mappings `collected = {"variable": [var1_at_x=1, var2_at_x=2, var4_at_x=4]}` -> there's some stuff in `merge.py` that could be reused for this
3. concatenate these lists to get a new mapping `concatenated = {"variable": [var_at_x=[1,2,4]]}`
4. apply `reindexed = {concatenated[var].reindex(x=[1,2,3,4], fill_value=...) for var in concatenated}`
5. create dataset `Dataset(reindexed)`

Step 1 would be where we deal with all the edge cases mentioned in @shoyer's comment viz

> For example:
> 
> Pre-existing vs non-pre-existing dimension
> Pre-existing dimensions of different sizes
> Missing data variables vs coordinates vs indexed coordinates

I just pushed an incomplete set of changes as @kmuehlbauer tests have demonstrated there was some incomplete cases the PR still isn't handling.  
Here is a summary:
1. I've simplified the logic based on @dcherian comments but in order to keep the result deterministic needed to use list logic instead of set logic.  I also kept the OrderedDict instead of going with the default dict as the built in ordering methods as of py 3.6 were still insufficient for keeping the ordering consistent (I needed to pop FIFO) which doesn't seem possible until py 3.8.
2. I did add a failing test to capture the cases @kmuehlbauer  pointed out.

I'm not sure I have my head wrapped around xarray enough to address @dcherian's latest comments though which is why i'm sharing the code at this point.  All tests are passing except the new cases which were pointed out.

I'll try to continue to get time to update this but wanted to at least provide this status update at this point as its been awhile.
Has this been implemented? Or is it still failing the tests?
Cool PR - looks like it's stale? Maybe someone should copy the work to a new one? Have been coming across this issue a lot in my work recently.
@scottcha Are you still around and interested to bring this along? If not I could try to dive again into this.
I'm still along and yes I do still need this functionality (I still sync back to this PR when I have data missing vars).  The issue was that the technical requirements got beyond what I was able to account for with the time I had available.  If you or someone else was interested in picking it up I'd be happy to evaluate against my use cases. 
Great @scottcha, I was coming back here too every once in an while to just refresh my mind with the ideas pursued here. I can try to rebase the PR onto latest main, if I can free some cycles in the following days for starters.
> I can try to rebase the PR onto latest main

I did try that a few months ago, but a lot has changed since the PR was opened so it might actually be easier to reimplement the PR?
Thanks @keewis for the heads up. I'll have a look and if things get too complicated a reimplementation might be our best option.
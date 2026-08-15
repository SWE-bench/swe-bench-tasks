This is a weird one! Let's debug.

First thought, this has something to do with using `FacetGrid` directly (which is discouraged). But no, we can reproduce using `relplot`:

```python
g = sns.relplot(
    data=test_data,
    col="type",
    x="date", y="value",
    kind="line", height=3,
    marker="o",
    facet_kws=dict(sharey=False),
)
```
![image](https://user-images.githubusercontent.com/315810/138967920-53b0558e-c7e1-48e9-a272-ca7670bff913.png)


Let's get rid of `FacetGrid` altogether, and set up the figure with matplotlib. Still there:

```python
f, axs = plt.subplots(1, 3, sharex=True, sharey=False, figsize=(7, 3))
kws =  dict(x="date", y="value", marker="o")
sns.lineplot(data=test_data.query("type == 'no_NA'"), **kws, ax=axs[0])
sns.lineplot(data=test_data.query("type == 'pd.NA'"), **kws, ax=axs[1])
sns.lineplot(data=test_data.query("type == 'np.nan'"), **kws, ax=axs[2])
f.tight_layout()
```
![image](https://user-images.githubusercontent.com/315810/138968180-d7a7b8ad-4221-4a78-9c03-f8dde883ed30.png)

Now we can focus on a single `lineplot` and simplify even further. Is it because the x values are strings? No:

```python
sns.lineplot(x=[1, 2, 3, 4], y=[1, 2, pd.NA, 1.5], marker="o")
```
![image](https://user-images.githubusercontent.com/315810/138968672-cfd19a6b-9749-40ee-beff-23b28ca26fd2.png)

Hm, 

```python
pd.Series([1, 2, pd.NA, 1.5]).dtype
```
```
object
```

What if we force that to numeric?
```python
sns.lineplot(
    x=[1, 2, 3, 4],
    y=pd.Series([1, 2, pd.NA, 1.5], dtype="Float64"),
)
```
![image](https://user-images.githubusercontent.com/315810/138968866-4b91d1ae-309e-4bee-ad39-3ae57a9ff8d8.png)

There we go. So why is this happening? Seaborn will invert the y axis if the y variable is categorical, and indeed, it thinks the y variable is categorical:

```python
sns._core.variable_type(pd.Series([1, 2, pd.NA, 1.5]))
```
```
'categorical'
```

But that's because of the object dtype:

```python
sns._core.variable_type(pd.Series([1, 2, pd.NA, 1.5], dtype="Float64"))
```
```
'numeric'
```

Seaborn *will* introspect and object-typed series and consider it numeric if every element is subclass of `numbers.Number`:

```python
def all_numeric(x):
    from numbers import Number
    for x_i in x:
        if not isinstance(x_i, Number):
            return False
    return True
```

This is intended to allow object-typed series that mix int and `np.nan`. But while `np.nan` is a `Number`, `pd.NA` is not:

```python
all_numeric(pd.Series([1, 2, pd.NA, 1.5]))
```
```
False
```

So this is happening because seaborn thinks your y variable is categorical in the case where you are using `pd.NA` for missing.
Now what to do about it?

On the one hand, I'm inclined to say that this is an example of seaborn behaving as expected and the weird behavior is upstream. I believe pandas is still considering `pd.NA` as ["experimental"](https://pandas.pydata.org/pandas-docs/stable/user_guide/missing_data.html#missing-data-na) and not to be fully relied on. Maybe this behavior will change in pandas in the future? I don't think seaborn should make any guarantees about behavior with experimental pandas features.

On the other hand it's still annoying, and I think I can see a path to this not being an issue: the `all_numeric` check could be run on a version of the Series after dropping null values:

```python
s = pd.Series([1, 2, pd.NA, 1.5])
all_numeric(s.dropna())
```
```
True
```

This code is deep in the core of seaborn and it shouldn't be changed without consideration and testing. But that feels like a reasonable solution.
Wow, that was insightful!

------

A useless comment first.
> using FacetGrid directly (which is discouraged)

Excuse me? This is my bible of data analysis: https://seaborn.pydata.org/tutorial/axis_grids.html
You might wanna write on top of that page in big red letters "DISCOURAGED!". But I believe it will still look as encouraging as before.

_I do use `relplot` and `catplot` occasionally, but `FacetGrid` is just more rigorous._

-----
I didn't know `pd.NA` was experimental. I think, we can close the issue just for that reason.

Doing a bit more debugging down the line, I realized how unreliable `pd.NA` is. I mean, why would having a `NULL` change the data type of the column? Judging by the docs this was not intentional...

Wanted to report it as a bug upstream and figured something. Here's some pandas fun

__As before__
```python
mock_data = pd.DataFrame({
    'date': ['0', '1', '2', '3'],
    'value': [1, 2, 1, 1.5]
})
assert pd.api.types.is_numeric_dtype(mock_data.value)  # passes
mock_data.value.type  # dtype('float64')

mock_data.loc[2, 'value'] = pd.NA
assert pd.api.types.is_numeric_dtype(mock_data.value)  # fails
mock_data.value.type  # dtype('O')
```

__Fixed__
```python
mock_data = pd.DataFrame({
    'date': ['0', '1', '2', '3'],
    'value': [1, 2, 1, 1.5]
})
mock_data.value = mock_data.value.astype(pd.Float64Dtype())
mock_data.value.dtype  # Float64Dtype()

mock_data.loc[2, 'value'] = pd.NA
assert pd.api.types.is_numeric_dtype(mock_data.value)  # still passes
mock_data.value.dtype  # Float64Dtype()
```

I reported it anyways. https://github.com/pandas-dev/pandas/issues/44199

-----
Went after with a debugger `_core.py`. Seems like that loop is indeed the best way to check for types. Once I add an `NA` to the column, even on the clean subsets the `dtype` obviously stays being `object`. I can only imagine the inefficiencies it would create for large datasets. So, `pd.NA` is a big no-no. Unless used with a workaround above.

But I think your proposed fix should be pretty harmless

https://github.com/mwaskom/seaborn/blob/a0f7bf881e22950501fe01feadfad2e30a2b748d/seaborn/_core.py#L1471
```python
if pd.isna(vector).all():
    return "numeric"
```
This is ran before `all_numeric`. And, I think, it should be generally safe to just
```python
vector = vector.dropna()
```
right after L1471.

------
> it shouldn't be changed without consideration and testing

Well, there's
https://github.com/mwaskom/seaborn/tree/master/seaborn/tests

Kidding. I'm closing this. Pandas should figure out its datatypes. A `NULL` changing columns `dtype` isn't something seaborn should be fixing. You can add a check for `pd.NA` in that loop, and throw a warning maybe.

> You might wanna write on top of that page in big red letters "DISCOURAGED!".

Well, the second paragraph does say

> The figure-level functions are built on top of the objects discussed in this chapter of the tutorial. **In most cases, you will want to work with those functions. They take care of some important bookkeeping that synchronizes the multiple plots in each grid.** This chapter explains how the underlying objects work, which may be useful for advanced applications.

And more importantly, in the [`FacetGrid`](https://seaborn.pydata.org/generated/seaborn.FacetGrid.html) API docs, there is a pretty salient warning message (though, true, in orange rather than red). (`FacetGrid` has more hidden pitfalls than the other two objects on that tutorial page).
If I had to guess, I'd think pandas thinks about the `pd.NA` objects as being downstream from the "nullable dtypes", and so the proper order of operations would be to set the dtype to `Float64` so you get `pd.NA` rather than insert `pd.NA` so you get `Float64`. I do hope they'd change that in the future though.

I'm going to reopen as there's a straightforward workaround within seaborn core, and this could bite in other ways (i.e. if you make a scatterplot with 10k points where you've inadvertently created an object-typed series with `pd.NA` in it, it's going to draw 10k ticks).

> Well, there's https://github.com/mwaskom/seaborn/tree/master/seaborn/tests

True true, although in general I would say that the test suite is a little weak specifically when it comes to missing data. It's easy to generate well-behaved datasets for testing; it's harder to generate datasets with all the odd patterns of missing data you see in real datasets, and this has been a source of bugs in the past.
Off-topic...

> there is a pretty salient warning message
I swear, I looked at that page yesterday and didn't see it. 

The tutorial is called "Building structured multi-plot grids". 
First example is 
```python
g = sns.FacetGrid(tips, col="time")
g.map(sns.histplot, "tip")
```
but according to you it should be 
```python
g = sns.displot(tips, x="tip", col="time")
```

I think the tutorial needs a bit of restructuring, like
1) High-level API
2) Using FacetGrid directly

The tutorial was written when `distplot`/`catplot`/etc didn't exist, so it still teaches the old way. And does so very convincingly. 

---> separate issue
@mwaskom 

shall I add some tests for `pd.NA` here?
https://github.com/mwaskom/seaborn/blob/ff0fc76b4b65c7bcc1d2be2244e4ca1a92e4e740/seaborn/tests/test_core.py#L1422

Seems like you even planned it before
https://github.com/mwaskom/seaborn/blob/ff0fc76b4b65c7bcc1d2be2244e4ca1a92e4e740/seaborn/tests/test_core.py#L1435

I'd add diverse test-cases with `pd.NA`. Then you can add the one-liner fix. 

This is very informative, thanks! 
I agree that the proposed fix would be great and that a col should be treated as numeric if all its non-null elements are 👍

I think in the case of Nones too, where matplotlib’s scatter() has expected behaviour (and I assume plot() too), this null handling would be amazing 🙌
Not sure though that I interpreted it as an upstream issue (would have hoped plotting would perform okay with an uncasted numeric column, as it probably still does with np.nans)
seaborn is not doing the wrong thing from a plotting perspective here, it is just treating the vector as categorical because a) it does not have a numeric dtype and b) not all of its elements are numbers. 
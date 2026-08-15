Is there a way to turn the xlabels off again or to increase the spacing between the xaxis labels and the figure titles?
Please turn this into a reproducible example, thanks. 
Here is an reproducible example.
The columtemplate has a `\n` at the end to prevent the longer title to overlap with the scaling indicator (for the lack of a better name).

```
data = (sns.load_dataset('iris').set_index('species')*1e7).reset_index()
g = sns.relplot(data=data, x='sepal_length', y='sepal_width', col='species', 
                col_wrap=2, height=2.5, facet_kws=dict(sharex=False, sharey=False))
g.set_titles(row_template="{row_name}", col_template="SOMEWHATLONG-{col_name}")
for axes in g.axes.flat:
    axes.ticklabel_format(axis='both', style='scientific', scilimits=(0, 0))
```

![image](https://user-images.githubusercontent.com/3391614/206541914-79e01cd2-1dbf-4df7-82a3-b2bc26716c1b.png)

Also seaborn 0.12.1.

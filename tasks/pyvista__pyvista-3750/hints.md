Can confirm, and I am seeing quite a few inconsistent results with the threshold filter. So this is not a user error!

 For example `inverter=True/False` should produce two logical inverses for this mesh, but it doesn't:
<img width="624" alt="Screen Shot 2022-11-16 at 11 18 48 PM" src="https://user-images.githubusercontent.com/22067021/202371190-7dcd64df-1882-4876-b4c3-43fe614913a6.png">


Second, depending on if `value` is a single value `0` or a range `[0, 0]` yields completely different results from the PyVista filter (but not in ParaView):


```py
p = pv.Plotter(notebook=0, shape=(1,2))
p.add_mesh(mesh.threshold(0, invert=False))
p.subplot(0,1)
p.add_mesh(mesh.threshold(0, invert=True))
p.link_views()
p.view_isometric()
p.show()
```

<img width="624" alt="Screen Shot 2022-11-16 at 11 20 01 PM" src="https://user-images.githubusercontent.com/22067021/202371391-393280c1-1091-4c61-82b2-e95e76b49327.png">


vs.

```py
p = pv.Plotter(notebook=0, shape=(1,2))
p.add_mesh(mesh.threshold([0, 0], invert=False))
p.subplot(0,1)
p.add_mesh(mesh.threshold([0, 0], invert=True))
p.link_views()
p.view_isometric()
p.show()
```

<img width="624" alt="Screen Shot 2022-11-16 at 11 20 34 PM" src="https://user-images.githubusercontent.com/22067021/202371476-cfd0fabb-daad-47db-acc5-855b43504f21.png">


This is not good... I'll start digging into this and see if I can fix the `threshold` filter such that I has consistency with itself and with ParaView

Thanks for taking a closer look. I should have mentioned that I get the same behavior on linux using a similar conda-forge setup.

I've found that ranges like `[1, 1]` work as expected to filter on values == 1, but to filter on zero, it needs to span a very small range:
```python
p = pv.Plotter(notebook=0, shape=(1,2))
p.add_mesh(mesh.threshold([-1e-30, 1e-30], invert=False))
p.subplot(0,1)
p.add_mesh(mesh.threshold([-1e-30, 1e-30], invert=True))
p.link_views()
p.view_isometric()
p.show()
```
which also logs this message three times:
> 2022-11-17 22:30:30.021 ( 559.089s) [        20F0C740]       vtkThreshold.cxx:96    WARN| vtkThreshold::ThresholdBetween was deprecated for VTK 9.1 and will be removed in a future version.

Another solution is to use [`extract_cells`](https://docs.pyvista.org/api/core/_autosummary/pyvista.StructuredGrid.extract_cells.html):
```python
mesh.extract_cells(mesh.cell_data.active_scalars != 0).plot()
mesh.extract_cells(mesh.cell_data.active_scalars != 1).plot()
```
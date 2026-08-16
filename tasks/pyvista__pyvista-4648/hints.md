`probe` uses [vtkProbeFilter](https://vtk.org/doc/nightly/html/classvtkProbeFilter.html).  Note that `vtkCompositeDataProbeFilter` is a subclass, and adds the ability to use Composite Data as in input (only one of the two slots in the algorithm).

`sample` uses [vtkResampleWithDataSet](https://vtk.org/doc/nightly/html/classvtkResampleWithDataSet.html#details).  This uses `vtkCompositeDataProbeFilter` under the hood, but also allows composite data to be used in both the source and the input.

So I propose that we deprecate `probe` and only keep `sample` and `interpolate`.

`imterpolate` is separate from the other two since it uses a different sampling/interpolation method. 
The pyvista standard, at least in my experience, is that we should generally expect the shape of the mesh to be equal to the mesh on which the filter attribute is called.  That is, `mesh1.filter(mesh2)` should return a mesh closer to `mesh1`.  This also enables `inplace=True` usage when possible.

So, if we were to keep `probe` we should switch the order of operation, and the deprecation/breaking change would have to be done carefully.  I still think it should be removed entirely instead as above, but wanted to lay out other options.
> So, if we were to keep `probe` we should switch the order of operation, and the deprecation/breaking change would have to be done carefully. I still think it should be removed entirely instead as above, but wanted to lay out other options.

From a design standpoint, we'd probably have to do the deprecation the same way: deprecating the old method and introducing a new one that has the right semantics. Switching the input and output is not the kind of change we should subject downstream to.
+1 to this, I've definitely been confused by it before. 

> The pyvista standard, at least in my experience, is that we should generally expect the shape of the mesh to be equal to the mesh on which the filter attribute is called. 

+1 again

> From a design standpoint, we'd probably have to do the deprecation the same way: deprecating the old method and introducing a new one that has the right semantics. Switching the input and output is not the kind of change we should subject downstream to.

deprecate `probe` and introduce `eborp` 😉 

+1 for `eborp`
Something similar came up [on this PR](https://github.com/pyvista/pyvista/pull/1040#issuecomment-739850576). To quote that comment of mine:
>  If the user sets nonsense data we should either raise, or pass it on to vtk which probably clamps internally (I haven't tested yet).

(later it was discussed that yes, VTK clamps values internally). I'm not sure we came back to this point later during the PR, but anyway we ended up letting VTK do its thing, whatever that was.

I'm still not sure that checking and raising makes most sense, but I agree that at least documenting these values would be nice. We apparently have a handful of these documented, but not the others. Then again if we find it to be worth specifying in the docstring, we might as well make it a hard check on our side.
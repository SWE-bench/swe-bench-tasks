This illustrates the problem.
![image](https://user-images.githubusercontent.com/8114497/172552528-5870a43c-689a-407b-8bee-627f70cdd46e.png)

The green dashed box is the current clickable Rect. It should be the black box, which can be specified using QuadPoints. However, the new Rect should be the dotted blue. 

This means that for PDF < 1.6 the dotted blue rectangle will be used, but that should still be better than the current solution (imagine rotating 90 degrees).

Marking this as a good first issue as the solution is more or less given. Some trigonometry is required to determine a to f. Then these points together with x and y should be used to determine the max/min x and y coordinate to determine the blue Rect.
Hi @oscargus, where are clickable areas defined in the code? I've looked in `backend_pdf.py` in `RendererPdf` class and also at `Text` class so far but can't see where this would be coming from.
This is the code in `draw_mathtext` and then there are more or less identical parts in `draw_tex` and `draw_text`.

https://github.com/matplotlib/matplotlib/blob/00cdf28e7adf2216d41fc28b6eebcee3b8217d5f/lib/matplotlib/backends/backend_pdf.py#L2157-L2167

Maybe one should create a method that competes the coordinates and generates the `link_annotation` object rather than continue duplicating code?
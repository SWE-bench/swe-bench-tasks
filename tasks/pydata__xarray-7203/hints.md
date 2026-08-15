cc @e-marshall @scottyhq 
So what's the solution here? Add another condition checking for more than a certain number of variables? Somehow check whether a dataset is cloud-backed?
I think the best thing to do is to not load anything unless asked to. So delete the `array.size < 1e5` condition.
This would be a pretty small change and only applies for loading data into numpy arrays, for example current repr for a variable followed by modified for the example dataset above (which already happens for large arrays):

<img width="711" alt="Screen Shot 2022-06-24 at 4 38 19 PM" src="https://user-images.githubusercontent.com/3924836/175749415-04154ad2-a456-4698-9e2c-f8f4d2ec3e1e.png">

---

<img width="715" alt="Screen Shot 2022-06-24 at 4 37 26 PM" src="https://user-images.githubusercontent.com/3924836/175749402-dd465f42-f13d-4801-a287-ddef68a173d2.png">

Seeing a few values at the edges can be nice, so this makes me realize how data summaries in the metadata (Zarr or STAC) is great for large datasets on cloud storage.  

Is the print still slow if somewhere just before the load the array was masked to only show a few start and end elements, `array[[0, 1, -2, -1]]`?
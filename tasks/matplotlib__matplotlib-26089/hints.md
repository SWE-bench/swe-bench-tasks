See also: https://discourse.matplotlib.org/t/legends-are-difficult-to-modify/21506
admins,Are we planning on implementing this or no?
I'm not sure why this was closed.  I think if a PR came in that did this in a non invasive way it should be fine.  
@jklymak @cocolato He closed it cause someone gave a thumbs down on my comment. I asked it cause I wanted to do it, but I still wanted a reasonable chance of getting approved, so I just wanted to check it was something we wanted. 
I'm not clear what the objection would be - but maybe @mwaskom has clarifying comments? 
Alright, I think I figured it out, although I was wondering I think update_loc might make the most sense in this context

@jklymak 

Heres something that technically works? Although, I am confused as to why set_loc is technically public, despite being called from the legend, but I fail to see the usefulness of having this function, as it seems unnecessary. it is also technically called from Legend object, so I fail to see why this is technically 'public'
```
def set_loc(self, loc):
      loc=self.codes.get(loc,'best')
      self._set_loc(loc)
```

I think a better idea would just be setting _set_loc(self, loc) to this just to avoid the unnecessary need to call Legend.codes.get()  from the client. 

```
def _set_loc(self, loc):
   #Line  I am currently considering adding
   loc=self.codes.get(loc,'best')
   # rest of the current _set_loc function
   self._loc_used_default = False
   self._loc_real = loc
   self.stale = True
   self._legend_box.set_offset(self._findoffset)
```

Thoughts?


@
It's not a good idea to change the current definition of `_set_loc`; a new `set_loc`/`update_loc` method might be more appropriate

Totally agree, `set_loc` (which I believe should be the name, consistently with other `set_*` methods), is what should be called by the user. Also, it makes sense to have the argument checking in the public method and not in the private method (any code calling the private should know that they are calling it correctly).

(If your approach works or not, I cannot really tell though.)
I have a question, is update_loc supposed to have any differences between _set_loc? I have issue seeing any differences between the implementation of the two methods other than the name, being public/private and update_loc internally calling  Legend.codes.get(loc, 'best')? Thank you!

@oscargus @cocolato 
This is _set_loc btw:
    def _set_loc(self, loc):
        # find_offset function will be provided to _legend_box and
        # _legend_box will draw itself at the location of the return
        # value of the find_offset.
        self._loc_used_default = False
        self._loc_real = loc
        self.stale = True
        self._legend_box.set_offset(self._findoffset)



IMO, `set_loc` is intended for external users and should accept more enumeration-like, explicitly meaning arguments like `center`、`best`、`upper left`, rather than get code from the class variable `Legend.codes.get(loc, 'best')`.  Perhaps it would be more appropriate to implement it through the `Artist.set()` method.

https://github.com/matplotlib/matplotlib/blob/b3bd929cf07ea35479fded8f739126ccc39edd6d/lib/matplotlib/artist.py#L147-L147

https://github.com/matplotlib/matplotlib/blob/b3bd929cf07ea35479fded8f739126ccc39edd6d/lib/matplotlib/artist.py#L1216-L1231

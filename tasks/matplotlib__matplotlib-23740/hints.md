Not directly related to #23502, but it may be that the logic for stealing and returning space should be discussed jointly.
Do we know when we changed to following the mappable's axes?   That seems like we made a mistake there, and this may be a release critical bug fix.  Marking as such to make sure it gets discussed.  
It was discussed at https://github.com/matplotlib/matplotlib/pull/12333#issuecomment-425660082 (see in particular @tacaswell's comment just below) and deprecated in https://github.com/matplotlib/matplotlib/pull/12443.

I still think the change is correct, we just need a better error message here.  We *could* make `plt.colorbar` fallback to the current axes in case the current mappable has no axes if we really want to, but `Figure.colorbar` should not (as that's something that exists outside of the pyplot world).
I think that issue refers to the problem of what axes to steal from whereas this one refers to which axes to give back to.  We can't assume the logic is reversible because we have a cax arguement and an ax argument to colorbar. 
I'm not sure I follow?  Isn't this issue still about who to steal from?
I'm sorry - I got confused by the reference to the other issue

I think I'm ok with expecting the user to provide an axes if they just make an axes-less mappable and and expect plt.colorbar to do something. We could fall back to the current axes but in this case I think that would _create_ an empty axes, which seems wrong as well. If they are creating their own mappable they have some savvy of our internals and can supply a cax argument.  
> but in this case I think that would create an empty axes, which seems wrong as well.

I agree this seems wrong, but I think stealing from the current axes (as problematic as that is) even if we have to create it is better than failing.  I could go either way on warning (and raising in the future) in the case of an "orphaned" mappable without an explicit axes passed or not.
I'm OK with going through a warning before completely killing this 
I disagree.  I think failing is better and the user can tell us what they want explicitly if we can't infer it.  
Discussed on the call, I have been convinced we should give a better error as this was previously warned.
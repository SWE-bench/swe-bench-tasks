Interesting situation.  To summarize:  with implicit VR and the four-byte length it uses, we can read in something longer than **Ex**plicit VR can write, because it uses only two bytes for encoding the length (for VRs like DS).

I say we catch the exception and re-raise with a meaningful error message.  If the user wants to truncate the data to avoid this, they can choose how to do so, i.e. what to leave out.  Or they can save the dataset using Implicit VR.  The error message could explain those two options.


> I say we catch the exception and re-raise with a meaningful error message

Agreed - I will have a go at this some time later. 
I have to admit that I was quite surprised to see this behavior - while I did know that implicit transfer syntax has other length fields, I never thought that this would ever matter.
Reopen as the fix is incorrect - the VR shall be changed to UN instead (see #900).
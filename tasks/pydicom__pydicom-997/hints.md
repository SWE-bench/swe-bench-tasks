The problem is that as far as I can tell there's no unambiguous way to determine the difference between one frame with multiple fragments and multiple frames of 1 fragment each when the Basic Offset Table (Part 5, Annex A.4 and Section 8.2) has no value. You can look at the NumberOfFrames value but that won't help if the number of fragments is larger than the number of frames (indicating one or more frames has multiple fragments).

I could add a parser that determines the number of Items in the Pixel Data, and if the BOT has no value then compare that against the number of frames and use that to determine the generator yields. It seems clunky though.

Anyone have a better idea?


As long as you are not speaking about arbitrary access to single frames, it shall be possible to ignore the offset table completely and just decode fragments sequentially, checking for the decoded frame size as you go along, and yield the next frame as soon as it has the correct frame size (or larger in case of padding). 

This is in case I didn't miss something here, and only valid for the generator as opposed to arbitrary frame access.
Ok, I did miss something here - the frame is not decoded by the generator, but only later by the pixel data handler, so we won't know the decoded fragment size at that point. 
We could change the logic respectively (hand over each fragment to the pixel handler for decoding), but that would change the behavior, and also may be slower (or not, not sure).

You could at least check if the number of frames is the same as the number of fragments (which is probably the most common case) and handle that case, and also the case where the number of fragment is a multiple of the number of frames (which is less sure), but for other cases, you really need to decode the data to be on the sure side. 
As I recall when I first did this some time ago,  I had an awful time trying to deal with frames and fragments.  I ended up just focusing on getting it to work with the EMRI images I had for test cases and not really worrying about individual frame boundaries.  I am pretty sure where the pixel handler code says "for frame in CompressedPixelDataSeq", it is actually looping over each fragment...

I am pretty sure the handlers will fail when there is more than one fragment per frame...

> I am pretty sure the handlers will fail when there is more than one fragment per frame..

In this case maybe it makes sense to restructure the code to use the handlers to decode each fragment. Not sure if this would be a compatibility issue for existing code, though. 
The test cases I added for jpeg_ls have a different number of fragments per frame in the sequence.  I have to imagine that if the the offset table is empty for a muiltframe image, then the best you can do is assume one fragment per frame (that is what the code currently does).  Reading the standard, it is unclear to me that having an empty offset table with more than one fragment per frame is valid.  

I would welcome a more expert opinion on this.  


As far as I can see, the standard does not enforce a value for the offset table in any case, so this would be valid. I have no idea if this is used in the real world, but I wouldn't exclude the possibility.
I just added some changes to #688 that change the jpeg_ls handler to more properly use generate_pixel_data_frame rather than decode_data_sequence.  This fixes the test case of multiple fragments per frame with an offset table.  

For the case of no offset table, then maybe we can just go fragment by fragment with:

```
for fragment in data:
    frame.append(fragment)
    try:
        decompress(frame)
        print "yea! this is a valid frame"
    except:
        print "not quite done yet"

```
Looks promising! I'm off to my day job now, may have another look in the evening.
I was thinking of modifying the frame generator so the following logic applies:
```
if no BOT value:
    if NumberOfFrames == (number of pixel data items):
        # Multiple fragments, one frame each
    elif NumberOfFrames == 1:
        # One or more fragments, one frame
    elif (number of pixel data items) == 1:
        # One fragment, one frame
    else:
        # Multiple fragments, but no way to tell what fragments are what frame
        raise exception, tell user they should use the 
            fragment generator and their own judgement?
```
In the last case I think the only way to generate the frame correctly is if the BOT has a value.

Edit - Or to try to decompress? But not all encapsulated data has to be compressed...
Is it guaranteed that decompressing a frame will fail if the frame isn't complete? What's the performance penalty for a failed decompress?
> I was thinking of modifying the frame generator so the following logic applies

I think this sounds good. The last case is the real problem, of course. I have been thinking about decompressing it, too, but I'm not sure how decompressing/decoding separate fragments behaves. 
A working but probably slow solution would be to try to decompress a fragment as proposed, and if that fails, or if the resulting image is too small for a frame, try again with another fragment appended (the decoder itself could do this incrementally, but we don't have control over that). I don't know if there is the possibility to decode fragments independently - that would be easier (e.g. no need to append fragments), but I doubt that.
Anyway, that would basically mean either to transfer a part of the generator logic to the pixel handlers, or make the generator dependend on the pixel handlers.
It would be good if we had some test data with multiple fragments per frame to check this... I may have to think a bit more about this, having no real experience in this field.
For all the JPEG syntaxes (Jpeg200, Jpeg-LS, jpeg), a single frame always ends with a End-of-Image (EOI in JPEG/JPEG-LS, EOC in JPEG2K) that is "FF D9".  If there are N frames, there should always be exactly N of those markers in the fragments.   

So, for JPEG family, we could loop over the fragments:

```

frame = bytearray()
for fragment in data:
    frame.extend(fragment)
    if "FFD9" in frame[-10:]:
        print "Hooray! The frame is done"
        break
    else:
        print "Still more to do"

```

Although the try decompress ... except should work with jpeg syntaxes, there is no requirement that a decoder fail on an incomplete frame (it could just return decompressed data and wait for more input) (the current api we use will fail on incomplete images - but no guarantees).  

For the RLE syntaxes, there is only one fragment per frame.

For uncompressed syntaxes, the size of each frame may be determined by BitsStored x Rows x Cols.


That is much better! As we don't support any other compressed syntaxes apart from JPEG and RLE syntaxes, this should be sufficient to handle these cases. This also makes it possible to get some kind of indexed access for the worst case by building up the missing offset table ourselves if needed.
That logic has to be in the handlers though, or at some intermediate level, as it is the same for all JPEG syntaxes.
Is it possible to hit FF D9 because that's the value at that offset, not because we're at the end of the frame? Or is this only in the JPEG pixel data handlers?

I keep getting confused whether were talking about the pixel data handlers or the generator functions in encaps.
This is only for JPEG handlers.  FF D9 is guaranteed to not be in the encoded data.  It is a reserved JPEG marker.
> I keep getting confused whether were talking about the pixel data handlers or the generator functions in encaps.

This is currently a bit mixed up. The current implementation of the generator functions does not know about specific transfer syntaxes - with the proposed PR this would change. Maybe the generator could ask the pixel handler about a fragment being the last in a frame in case it doesn't know that, and the JPEG pixel handlers implement the logic (which should be in some common place for all JPEG handlers)?

@rhaxton @scaramallion - this would be a good candidate for 1.2, in my opinion. Is this doable? Do you need help for the conflict resolving?
@rhaxton, @scaramallion, pinging on this issue again ... was this ever resolved completely? I'll assign to v1.4 milestone for now, perhaps we can try to look at this in the coming months?
Hello @rhaxton! Thanks for updating the PR.











Cheers ! There are no PEP8 issues in this Pull Request. :beers: 

##### Comment last updated on August 06, 2018 at 18:28 Hours UTC
@mrbean-bremen If you could take a quick look at this particularly why there are issues with python 3, that would be a great help...

This will still fail for uncompressed frames with no BoT value.

Also the docstrings need updating.
I've been thinking it might be better to change `get_frame_offsets` to return an empty list if the BoT has no value rather than trying to be clever about it since the two cases (BoT has no value and BoT has single 0 offset) may represent different things. Then the functions that rely on it should be updated accordingly.
Can someone come up with a test case for an encapsulated uncompressed PixelData image?  I can't figure out how to create one with dcmtk...
Also, the standard explicitly calls out RLE syntax as having one fragment per frame, and calls out JPEG as possibly having more than one fragment per frame, but I couldn't find any statement about the fragments per frame for uncompressed syntax.  Any ideas on that one?
I have some code I'm working on that should at least return mixed fragments/frame native data in a single blob while still following your approach for JPEG data.

```python
# N fragments, M frames; without BOT values there's no generic
#   way to determine where a frame ends so we try our best
frame = []
frame_number = 0
for fragment in generate_pixel_data_fragment(fp):
    # For JPEG transfer syntaxes try to locate the EOC marker
    if b'\xFF\xD9' in fragment[-10:]:
        yield tuple(frame)
        frame_number += 1
        frame = []
    else:
        frame.append(fragment)

# If we failed to locate the EOC marker then either nothing will
#   have been yielded and/or one or more frames will have been
#   skipped. This will be the case with native transfer syntaxes
if frame_number != no_frames:
    yield tuple(frame)
```

[Here](https://github.com/pydicom/pydicom/files/2252088/encap_jpeg.zip) is some JPEG 2x2 11 frame encapsulated data with and without BOT (1 fragment per frame and 2 fragments per frame).

[Here](https://github.com/pydicom/pydicom/files/2252147/encap_native.zip) is some native 2x2 11 frame encapsulated data with and without BOT (1 fragment per frame and 2 fragments per frame).

Image pattern is black upper left, white upper right, white lower left, black lower right and the black pixels shade to white over the frames. Maybe just double check the encapsulation has been performed correctly. 

With the code above the no BOT/native/2 fragments per frame returns a blob of the entire pixel data, but I'd expect that in that case the numpy pixel handler should be able to rearrange the data into frames correctly, provided the blob is the right length. The no BOT/jpeg/2 fragments per frame returns the frames correctly.
I'm a bit confused by this.  When I read [this section](http://dicom.nema.org/dicom/2013/output/chtml/part05/sect_8.2.html) of DICOM,  it seems to imply that Uncompressed and Encapsulated are mutually exclusive?  I don't know if I have ever seen a DICOM uncompressed image with encapsulated pixel data.  Has anyone else?

Whoops, obviously I've gotten confused about this somewhere. Nevermind me then...

[This is what I've done.](https://github.com/scaramallion/pydicom/blob/dev-encaps/pydicom/encaps.py#L247)
@rhaxton , @scaramallion - what is the state of this PR (apart from having conflicts) - can it make it into the 1.4 release?
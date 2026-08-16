Add Tag and VR to the bulk data handling in `from_json`
Currently, if you convert back to a Dataset format from a JSON format, you MUST re-hydrate all of the bulk data URI's or you will loose the information.

This causes a problem if you just wish to use the Dataset's header (maybe to extract some data, or rearrange some data), because now you have to pay the cost of getting all the pixel data and then handling the pixel data again upon conversion back to JSON

**Describe the solution you'd like**
Add the tag and the vr to the bulk data handler in `from_json` (this can be done in a backwards compatible way). This will allow the user to store the BulkDataURI's by tag in a map, return dummy data large enough to trigger the bulk handling when to_json is called next, and to use the map to convert back to the original URI's when bulk handling is triggered from to_json.

I'm going to drop a PR tomorrow that does this in a fully backward compatible, non-breaking fashion.


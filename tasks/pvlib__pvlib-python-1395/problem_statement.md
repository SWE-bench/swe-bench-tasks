Add retrieval function for horizon profile from MINES Paris Tech
<!-- Thank you for your contribution! The following items must be addressed before the code can be merged. Please don't hesitate to ask for help if you're unsure of how to accomplish any of the items. Feel free to remove checklist items that are not relevant to your change. -->

 - [x] I am familiar with the [contributing guidelines](https://pvlib-python.readthedocs.io/en/latest/contributing.html)
 - [x] Tests added
 - [x] Updates entries to [`docs/sphinx/source/api.rst`](https://github.com/pvlib/pvlib-python/blob/master/docs/sphinx/source/api.rst) for API changes.
 - [x] Adds description and name entries in the appropriate "what's new" file in [`docs/sphinx/source/whatsnew`](https://github.com/pvlib/pvlib-python/tree/master/docs/sphinx/source/whatsnew) for all changes. Includes link to the GitHub Issue with `` :issue:`num` `` or this Pull Request with `` :pull:`num` ``. Includes contributor name and/or GitHub username (link with `` :ghuser:`user` ``).
 - [x] New code is fully documented. Includes [numpydoc](https://numpydoc.readthedocs.io/en/latest/format.html) compliant docstrings, examples, and comments where necessary.
 - [x] Pull request is nearly complete and ready for detailed review.
 - [x] Maintainer: Appropriate GitHub Labels and Milestone are assigned to the Pull Request and linked Issue.

<!-- Brief description of the problem and proposed solution (if not already fully described in the issue linked to above): -->

The proposed function retrieves the local horizon profile for a specific location (latitude, longitude, and elevation). The returned horizon profile has a resolution of 1 degree in the azimuth direction. The service is provided by MINES ParisTech though I cannot find any official documentation for it.

The function added in this PR (``pvlib.iotools.get_mines_horizon``) is very similar to the function added in #1395 (``pvlib.iotools.get_pvgis_horizon``).

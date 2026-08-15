@yukiisbored Just to be clear, if the url is

- `https://github.com/org/repo#anchor`, or
- `https://github.com/org/repo/blob/main/file.ext#anchor`,

you want `linkcheck` to only check that `https://github.com/org/repo` and `https://github.com/org/repo/blob/main/file.ext` exist **without** checking the anchors in the README or in `file.ext` respectively ? 
@picnixz yup, that is correct.
In addition to the data contained in the instances, pickle also stores a string reference to the original class. This means that Row tuple class should be in query module globals so pickle can find the reference. But besides that, it should have different class names for each model and for each list of values.
​PR
You shouldn't mark your own PRs as ready for checkin.
This is because the property raises an `AttributeError`, which causes Python to call `__getattr__`. You can catch the `AttributeError` in the property and raise another exception with a better message.
The problem is it's a nightmare for debugging at the moment. If I had a bunch of different attributes in `prop(self)`, and only one didn't exist, there's no way of knowing which one doesn't exist. Would it possible modify the `__getattr__` method in `SkyCoord` to raise the original `AttributeError`?
No, `__getattr__` does not know about the other errors. So the only way is to catch the AttributeError and raise it as another error...
https://stackoverflow.com/questions/36575068/attributeerrors-undesired-interaction-between-property-and-getattr
@adrn , since you added the milestone, what is its status for feature freeze tomorrow?
Milestone is removed as there hasn't been any updates on this, and the issue hasn't been resolved on master.
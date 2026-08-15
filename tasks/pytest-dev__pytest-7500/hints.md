Hi @stanwest,

The order should not really matter in that situation, what might be happening is that by first cleaning up the `garbage-*` directories, this is giving more time for whatever is holding the locked directories to release that lock (say a background process), and then it might appear to solve the problem.

I believe the proper solution is to explicitly catch errors around that `exists` call, and assume it is locked in case of any errors. 
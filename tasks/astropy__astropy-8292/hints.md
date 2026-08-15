Note: This was implemented in #7970
(I removed the `cosmology` label b/c this is not actually part of the cosmology package - it's really just units)
Thanks for catching this @dr-guangtou - indeed it's definitely wrong - was right in an earlier version, but somehow got flipped around in the process of a change of the implementation (and I guess the tests ended up getting re-written to reflect the incorrect implementation...).  

milestoning this for 3.1.1, as it's a pretty major "wrongness"
Seems like a good idea, although I am afraid we may get more pushback regarding "needless deprecations" from old, large Django projects that use it. A middle ground could be to remove it from the documentation. Would you like to write to the DevelopersMailingList to see what others think?
The smart if tag which made ifequal redundant was introduced in Django 1.2. Really, ifequal should have been deprecated then. I agree this is a good candidate for deprecation, and I'd rather take a bit of flak for "needless" deprecations than keep tested (?) but undocumented code around forever.
​Submitted to the dev mailing list.
In a3830f6: Refs #25236 -- Removed ifequal/ifnotequal usage.
In 787cc7a: Refs #25236 -- Discouraged use of ifequal/ifnotequal template tags.
Moving to "Someday/Maybe" as we have multiple complaints on the ​mailing list that updating projects for this removal will be too onerous to justify the cleanup.
In 21128793: [1.8.x] Refs #25236 -- Discouraged use of ifequal/ifnotequal template tags. Backport of 787cc7aa843d5c0834f56b5f8ae03b86ce553c51 from master
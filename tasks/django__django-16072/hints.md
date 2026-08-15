It could have a noticeable impact on PostgreSQL to not update these columns in some scenario as are they are likely to be indexed if matched against (Write Amplification problem)
​PR
​New PR
Tentatively removing the patch_needs_improvement flag, there is a comment about clarifying existing documentation but not sure if that needs to be included in this PR :)
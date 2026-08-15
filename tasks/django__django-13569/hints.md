Patch to SQLCompiler.get_group_by that excluds Random expressions
​PR
I wonder what would happen if we skipped all expressions that have no cols as source expressions (plus, we need to include any raw sql).
I wonder what would happen if we skipped all expressions that have no cols as source expressions (plus, we need to include any raw sql). This seems like a very good idea, and I can’t think of a scenario where this will break things. I’ve updated the PR.
The new test isn't passing on MySQL/PostgreSQL.
Some test additions are still needed.
It's documented that ordering will be included in the grouping clause so I wouldn't say that this behavior is unexpected. It seems to me that trying to remove some (but not all) columns from the group by clause according to new rules is less clear than the simple rule that is in place now.
If you need to filter on an annotated value while still using .order_by('?'), this could work: Thing.objects.filter(pk__in=Thing.objects.annotate(rc=Count('related')).filter(rc__gte=2)).order_by('?') This avoids the GROUP BY RANDOM() ORDER BY RANDOM() ASC issue while still allowing .annotate() and .order_by('?') to be used together.
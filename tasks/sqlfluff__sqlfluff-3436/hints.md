I'll take a look.

And darn it -- first bug report against this code in the past couple months, I think. 😅
Starting to look at this. One problem I noticed (perhaps not the only one) is that the trailing literal newline in the source string has no corresponding templated slice, so it's like building the templated slice array has stopped early for some reason.

The 0-length slices may be legit. Will share more as I learn things, but is `{% block %}` a Jinja builtin or an extension? If it's an extension, maybe base Jinja is just skipping it (i.e. rendering it as empty string). 
Ok, I think the issue is not related to undefined variables. I get the same assertion error if I define the variable prior to the block, e.g.:
```
{% set table_name = "abc" %}
SELECT {% block table_name %}a{% endblock %} FROM {{ self.table_name() }}
```

I'm pretty sure the real issue is that we aren't handling `{% block %}` correctly **at all** (probably because I hadn't heard of it before 🤪).

II think it should be handled similarly to `{% set %}` or `{% macro %}` blocks, i.e. basically don't trace when they are **defined**, only when they are **used**.

I should be able to fix it this week. For now, just need to let my brain recover from looking at this code again. Even though I wrote it, it's a little too "meta" for me to stare at it for more than 1-2 hours at a time. 😅
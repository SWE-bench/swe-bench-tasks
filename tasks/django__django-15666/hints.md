Started working on a fix.
​PR Looking for feedback on this patch.
After 8c5f9906c56ac72fc4f13218dd90bdf9bc8a248b it crashes with: django.core.exceptions.FieldError: Cannot resolve keyword 'instrument' into field. Choices are: artist, artist_id, id, name, num_stars, release_date
#33678 was a duplicate for functions in related Meta.ordering.
If anyone is interested in addressing this ticket there's a possible implementation detailed in https://code.djangoproject.com/ticket/33678#comment:3
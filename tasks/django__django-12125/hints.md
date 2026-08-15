This should be possible to do by relying on __qualname__ (instead of __name__) now that master is Python 3 only.
​PR
I think we should focus on using __qualname__ during migration serialization as well instead of simply solving the field subclasses case.
In fb0f987: Fixed #27914 -- Added support for nested classes in Field.deconstruct()/repr().
In 451b585: Refs #27914 -- Used qualname in model operations' deconstruct().
I am still encountering this issue when running makemigrations on models that include a django-enumfields EnumField. From tracing through the code, I believe the Enum is getting serialized using the django.db.migrations.serializer.TypeSerializer, which still uses the __name__ rather than __qualname__. As a result, the Enum's path gets resolved to app_name.models.enum_name and the generated migration file throws an error "app_name.models has no 'enum_name' member". The correct path for the inner class should be app_name.models.model_name.enum_name. ​https://github.com/django/django/blob/master/django/db/migrations/serializer.py#L266
Reopening it. Will recheck with nested enum field.
​PR for fixing enum class as an inner class of model.
In d3030dea: Refs #27914 -- Moved test enum.Enum subclasses outside of WriterTests.test_serialize_enums().
In 6452112: Refs #27914 -- Fixed serialization of nested enum.Enum classes in migrations.
In 1a4db2c: [3.0.x] Refs #27914 -- Moved test enum.Enum subclasses outside of WriterTests.test_serialize_enums(). Backport of d3030deaaa50b7814e34ef1e71f2afaf97c6bec6 from master
In 30271a47: [3.0.x] Refs #27914 -- Fixed serialization of nested enum.Enum classes in migrations. Backport of 6452112640081ac8838147a8ba192c45879203d8 from master
commit 6452112640081ac8838147a8ba192c45879203d8 does not resolve this ticket. The commit patched the EnumSerializer with __qualname__, which works for Enum members. However, the serializer_factory is returning TypeSerializer for the Enum subclass, which is still using __name__ With v3.0.x introducing models.Choices, models.IntegerChoices, using nested enums will become a common pattern; serializing them properly with __qualname__ seems prudent. Here's a patch for the 3.0rc1 build ​https://github.com/django/django/files/3879265/django_db_migrations_serializer_TypeSerializer.patch.txt
Agreed, we should fix this.
I will create a patch a soon as possible.
Submitted PR: ​https://github.com/django/django/pull/12125
PR: ​https://github.com/django/django/pull/12125
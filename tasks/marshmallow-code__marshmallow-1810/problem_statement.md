3.12 no longer supports fields named `parent`
Pretty sure that #1631 broke it. Reproducible example:

```py
from marshmallow import INCLUDE
from marshmallow.fields import Nested
from sqlalchemy import Column, DATE, create_engine, ForeignKey
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import declarative_base, relationship
from marshmallow_sqlalchemy import SQLAlchemyAutoSchema
from testing.postgresql import Postgresql


Base = declarative_base()


class Author(Base):
    __tablename__ = 'author'
    id = Column(UUID(as_uuid=True), primary_key=True)
    docs = relationship('Document', back_populates='parent')


class Document(Base):
    __tablename__ = 'document'
    id = Column(UUID(as_uuid=True), primary_key=True)
    parent_id = Column(UUID(as_uuid=True), ForeignKey('author.id'))
    parent = relationship(Author, back_populates='docs')
    last_updated = Column(DATE)


class AuthorSchema(SQLAlchemyAutoSchema):
    class Meta(SQLAlchemyAutoSchema.Meta):
        model = Author


class DocumentSchema(SQLAlchemyAutoSchema):
    parent = Nested(AuthorSchema)

    class Meta(SQLAlchemyAutoSchema.Meta):
        model = Document


with Postgresql() as postgresql:
    url = postgresql.url(drivername='postgresql+psycopg2')
    engine = create_engine(url, echo=True)
    Base.metadata.create_all(engine)

    DocumentSchema(unknown=INCLUDE)
```

Results in:

```pytb
Traceback (most recent call last):
  File "/home/phil/.config/JetBrains/PyCharm2021.1/scratches/sqlalchemy-marshmallow-reprex.py", line 44, in <module>
    DocumentSchema(unknown=INCLUDE)
  File "/home/phil/Dev/Python/venvs/cellarity/lib/python3.9/site-packages/marshmallow_sqlalchemy/schema/load_instance_mixin.py", line 43, in __init__
    super().__init__(*args, **kwargs)
  File "/home/phil/Dev/Python/venvs/cellarity/lib/python3.9/site-packages/marshmallow/schema.py", line 392, in __init__
    self._init_fields()
  File "/home/phil/Dev/Python/venvs/cellarity/lib/python3.9/site-packages/marshmallow/schema.py", line 971, in _init_fields
    self._bind_field(field_name, field_obj)
  File "/home/phil/Dev/Python/venvs/cellarity/lib/python3.9/site-packages/marshmallow/schema.py", line 1030, in _bind_field
    field_obj._bind_to_schema(field_name, self)
  File "/home/phil/Dev/Python/venvs/cellarity/lib/python3.9/site-packages/marshmallow/fields.py", line 1201, in _bind_to_schema
    or getattr(self.root.opts, self.SCHEMA_OPTS_VAR_NAME)
AttributeError: 'NoneType' object has no attribute 'opts'
```

Here, `self.root` resolves to `None` for the `last_updated` field:

https://github.com/marshmallow-code/marshmallow/blob/69270215ab9275dc566b010ecdb8777c186aa776/src/marshmallow/fields.py#L411-L420

This happens since that field’s `.parent` is the `DocumentSchema` class, which *does* have a `.parent` attribute. However that attribute is a `Nested` instance, not another schema as expected
Return a field’s root schema as soon as it is found
This prevents accessing a schema’s `.parent` attribute if it has one (e.g. a field called `parent`)

Fixes #1808, I think.

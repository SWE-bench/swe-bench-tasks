OK, grrrr... — Just a case of doc-ing the limitations. 🤨 (Thanks)
Draft.
I've attached a draft solution but it's really hot and it doesn't handle list with dicts (...deep rabbit hole). IMO we should drop support for these lookups on SQLite, at least for now. Testing containment of JSONField is really complicated, I hope SQLite and Oracle will prepare native solutions in future versions.
It looks like if you request `http://localhost:5000/child/`, you'll get 200 OK.

It means that when registering child blueprints, they don't respect the subdomain set by the parent.

I submitted a PR at #4855.
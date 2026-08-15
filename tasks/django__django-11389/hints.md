I've created a pull request: ​https://github.com/django/django/pull/9318
That seems useful.
Actually, it looks like you can call SessionStore.set_expiry? One place to do so would be in a middleware that's listed below the session middleware, when processing a response. class SessionExpiryPolicyMiddleware(object): def __init__(self, get_response): self.get_response = get_response def __call__(self, request): response = self.get_response(request) if response.session.modified and response.status_code != 500: response.session.set_expiry(response.session.calculate_expiry()) return response
You are right that could be a way to achieve this, I know there are other ways to do this but don't you think that the responsible of calculating Session expirations should be the SessionStore not a middleware?
I think it would be worth discussing in the django-developers mailing list.
A test should be added so the change isn't inadvertently refactored away.
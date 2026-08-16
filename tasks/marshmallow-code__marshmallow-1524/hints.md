`^` behaves as expected, but `$` also matches a "string-ending newline". This appears to be a holdover from POSIX that most languages have long abandoned as default behavior.

Thanks for reporting this @nbanmp. If you are interesting in contributing a MR, I would be happy to review it, otherwise I can pick this up as soon as I get a chance.

Also, can you provide any examples of using an email address in a way that would make this issue a security vulnerability? The best I can come up with is that it will terminate the email headers early and cause an email to be malformed or undeliverable, which would be a standard bug. Since the newline can only be at the very end of the string, this would not allow injecting additional headers into an email. If it does have security implications I can submit a CVE and flag the vulnerable versions on TideLift.
I don't know if I would call this a vulnerability in marshmallow, but it might - in rare cases - allow for exploitation of certain vulnerabilities in other tools.

The most likely place this might result in a vulnerability is when verifying an email for authentication, and allowing multiple accounts with the same, but different emails.

A minor form of this would be allowing the same email to be used multiple times in sites that want to prevent that.

A more serious, but unlikely form of this would be something like:

Depending on how emails are stored / used, whitespace around them might be stripped or not between sending emails, and checking emails. It's not a vulnerability in marshmallow itself, but it might result in inconsistencies in other apps lead to actual vulnerabilities.

```python
validateemail(email)

if email in database:
    error()
else:
    saveaccount(email.strip(), password) # This might overwrite an account with the correct email
```

This example is actually what I was thinking of, because I was looking through the code for CTFd, which had a similar vulnerability occurring with the username, and, if not for dumb luck (a random lack of .strip() / it being in a different place), the same vulnerability would have also been possible using the email, even though the email was invalid.

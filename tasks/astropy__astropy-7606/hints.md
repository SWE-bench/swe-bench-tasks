`x is None` works fine. Is there a reason why `==` is needed here?
`x is None` would indeed be preferred, but `==` should never fail, so this is still a bug.
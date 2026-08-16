Sounds similar to #1458 where we should handle "empty" statement/files better?
Nope, that's the different issue. I doubt that solving one of them would help in other one. I think both issues should stay, just in the case.
But what do you think @tunetheweb - should it just ignore these `;;` or raise something like `Found unparsable section:`? 
Just tested and in BigQuery it's an error.
Interestingly Oracle is fine with it.

I think it should be raised as `Found unparsable section`.
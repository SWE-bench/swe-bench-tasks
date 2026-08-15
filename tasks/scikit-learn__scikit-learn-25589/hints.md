Thank you for opening the issue! In this case, API-wise I think `drop_idx` is defined incorrectly and should be `1` point to `b`, because it is the categorical that is actually dropped. 

There seems to be a bigger issue with how `drop_idx` is defined when there are any infrequent categories. I am looking into a fix.
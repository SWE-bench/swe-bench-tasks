Hello,

I would like to work on this issue. Could you please guide me?
I have tested with indices=[] and in most of the cases it works fine except that we want to explicitly change the output. So I suppose that a default value [] can be set to 'indices' so that it can become optional. Would that be a possible solution?
But while trying to verify this idea and looking into the code, I am a little bit lost.  Especially for the _match_indices_with_other_tensor who has two indices parameters. 

`    def _match_indices_with_other_tensor(array, free_ind1, free_ind2, replacement_dict):`

Is free_ind means the indices for no-replaced expression?

If the [] parameter is not robust enough, I am also thinking about automatically adding default indices in the function. That is to get indices from the expression itself. But this approach has a difficulty is that tensorhead doesn't have the get_indices function. 

What do you think about it? Could you please give me some advices? Thank you!

If there is no-one working on this issue I can do it.

By the way, I believe pandas supports one hot encoding found [this](https://stackoverflow.com/questions/37292872/how-can-i-one-hot-encode-in-python) on StackOverflow 

What are your thoughts on detecting that it is a pandas dataframe and using pandas native encoder ? 
I don't think we want to use `pd.get_dummies` for now (assuming you are referring to that). Even apart from the question if we would want to depend on it, it does not give us everything that would be needed for the OneHotEncoder (eg specifying categories per column, handling unknown values, etc).

But feel free to work on this! 
Perfect I'll work on this !
Just to add, one key challenge when returning an array is mapping feature importances back to the original column names when you've applied OneHotEncoder.

It would be a big step forward to replace the prefixes `x0_`, `x1_`, etc with the proper column names.

See https://stackoverflow.com/q/54570947/3217870
We will try to tackle this one during the sprints in Paris this week.
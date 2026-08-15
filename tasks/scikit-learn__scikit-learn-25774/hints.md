I am adding some thinking that we had with @GaelVaroquaux and @ogrisel. @GaelVaroquaux is not keen on discarding missing values because you are introducing another type of bias.

As an alternative to the current implementation, I would suggest the following proposal:

- Make the behaviour consistent by raising an error if missing values are provided for the next 1.2.2 release. It is a bit the only way that we have if we don't want to include new API changes.
- For 1.3 release, modify `partial_dependence` to treat specifically missing values. The idea would be to store them separately in the return `Bunch`. Then, we can make treat them independently as well in the plot where it will correspond to a horizontal line for the numerical case and a specific column for the categorical case.

Raising an error is a bit more restrictive than what was originally proposed but the future behaviour since more reliable.

@betatim @lorentzenchr Any thoughts or comments on this alternative proposal?
> @GaelVaroquaux is not keen on discarding missing values because you are introducing another type of bias.

Yes: discarding samples with missing values (known as "list-wise deletion in the missing values literature) creates biases as soon as the data are not missing at random (aka most often in real-life cases), for instance, in the case of self-censoring (a value is more likely to be missing if it is higher or lower than a given threshold).

For a visualization/understanding tool, such biases would be pretty nasty.


Repeating back what I understood: for now make it an error to pass data with missing values to the partial dependence computation. This is a change for numerical features as they used to raise an exception until v1.2, for categorical features an exception is being raised already.

In a future version we build something to actually take the missing values into account instead of just discarding them.

Is that about right? If yes: 👍 
> Is that about right? If yes: 👍

Yes, indeed.
> - Make the behaviour consistent by raising an error if missing values are provided for the next 1.2.2 release. It is a bit the only way that we have if we don't want to include new API changes.
> - For 1.3 release, modify partial_dependence to treat specifically missing values. The idea would be to store them separately in the return Bunch. Then, we can make treat them independently as well in the plot where it will correspond to a horizontal line for the numerical case and a specific column for the categorical case.

Sounds reasonable. Thanks for giving it a second thought! The connection from ignoring NaN in quantiles to silently supporting (by neglecting) NaN values in partial dependence slipped my attention.
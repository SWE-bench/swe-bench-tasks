I would like to work on this.

@asmeurer  Regarding the issue 1 . I find it outputs something else on the sympy live shell . Kindly have a look . 

> > > str(Interval(0, 1, False))
> > > [0,1]
> > > 
> > > str(Interval(0, 1, True))
> > > (0,1]

Also, 

> > > type(str(Interval(0, 1, False)))
> > > <type′str′>
> > > 
> > > type(str(Interval(0, 1, true)))
> > > <type′str′>

The output is the same on sympy live

@AnishShah  but here have a look at this screenshot of what i tried on sympy live.
![image](https://cloud.githubusercontent.com/assets/10466576/13282607/cb860554-db0f-11e5-8011-2ed2702fee66.png)

If I am going wrong somewhere then kindly guide.

I'm sorry if I'm missing something, but the output in your screenshot is same as the output mentioned by @asmeurer. I don't see any difference.

'[0, 1]' and [0, 1] . I think it is already a string after getting evaluated by str.

@SalilVishnuKapur that's because the SymPy Live shell renders the output as LaTeX. 

You should work locally against the git master. SymPy Live has some differences against the normal SymPy which might confuse, but more importantly, it runs SymPy 0.7.6, whereas you want to work against the git master. 

I would like to take this up. :)

I also want to work on this but i am new here so  how should start?

It looks like this has already been started at https://github.com/sympy/sympy/pull/10708, so you should at least wait until that is merged and see if anything is left to do then. 

Also see https://github.com/sympy/sympy/wiki/Development-workflow for general instructions on how to contribute. 

Ohkk thanks Aaron Meurer!!!  I will wait for that or I will work on other Issue. Thanks for suggestion.

Related https://github.com/sympy/sympy/issues/10035

@asmeurer 
Please review PR #12112 
https://github.com/sympy/sympy/issues/12213
@Upabjojr wrong number? I don't see how that's related. 
> wrong number? I don't see how that's related.

Sorry, I wanted to link the issue of the `And` and `Or` str() printer.
Please review #12112 
@Upabjojr I don't think this issue should be closed. #12112 takes care of only `str` printer. `srepr` printer is still the same.
@SagarB-97 github apparently closed the issue automatically, I didn't actually notice that.
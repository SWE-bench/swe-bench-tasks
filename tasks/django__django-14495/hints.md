I agree, that should be possible and I think it is possible.
Just ran into this. FWIW, workaround, as long as we do not do what comment:5:ticket:24902 recommends (which is to keep the state of squashed migrations in the db), is to simply move the squashed migration file away, migrate backwards to your heart's content, then bring it back.
​PR
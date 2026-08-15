The solution clearly is that BlockDiagMatrix should convert MutableMatrix to ImmutableMatrix.

I bisected to b085bab7427ce6b5c2ad7657f216445659b5c4a1

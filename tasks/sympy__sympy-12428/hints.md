ping @bhavishyagopesh at #12316 
@smichr I found something really strange(only if I'm not mistaken)
`from sympy import *`
`from sympy import Q as Query`
`x=Matrix([[1,0,0],[0,2,0],[0,0,3]])`
`d = DiagonalMatrix(x)`
`d[1,1]`

It returns zero but should return 2, I think its becoz "/matrices/expressions/diagonal.py" line : 11,(I used trace), it returns `self.arg[i, 0]` when `i==j`why?
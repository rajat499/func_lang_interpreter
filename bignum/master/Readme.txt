This is a preliminary assignment which will be used in following 
assignments.  In this assignment, you will write in OCaml a 
BIGNUM package  where you will implement arithmetic for 
arbitrarily large numbers, using lists of digits to implement
an integer.



The data type can be represented in OCaml as

type bigint = sign * int list                           @done

and sign = Neg | NonNeg;;                               @done

with the representational invariant that the 
elements of the int list are between 0 and 9, 
and are presented most significant digit first, 
and that there are no unnecessary leading zeros.

You will need to implement the following operations in the package:

Arithmetic operations: 
Addition.  add: bigint -> bigint -> bigint              @done
Multiplication.  mult: bigint -> bigint -> bigint       @done
Subtraction.  sub: : bigint -> bigint -> bigint         @done
Quotient:   div: : bigint -> bigint -> bigint           @done
Remainder.  rem: : bigint -> bigint -> bigint           @done
Unary negation.  minus: bigint -> bigint                @done
Absolute value.  abs: bigint -> bigint                  @done


Comparison operations: 
Equal.   eq: bigint -> bigint -> bool                   @done
Greater_than.  gt:  bigint -> bigint -> bool            @done
Less_than.  lt:  bigint -> bigint -> bool               @done
Great_or_equal.  geq:  bigint -> bigint -> bool         @done
Less_or_equal.  leq:  bigint -> bigint -> bool          @done


Functions to present the result in the form of a string. 
print_num:  bigint -> string                                                @done
Conversion functions from OCaml int to bigint.
mk_big:  int -> bigint                                                      @done
Define suitable exceptions when an operation is not defined.


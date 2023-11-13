addi x3, x0, 3  				#the number for which we want to find factorial, n
blt x3, x0, negative_and_zero   #if n < 1 then return 1
beq x3, x0, negative_and_zero   #if n == 0 then return 1

addi x1, x0, 2					#used for comparison
beq x3, x1, two                 #find factorial of 2

add x4, x0, x3      			#result will be stored in this register
add x2, x0, x3                  #copy of n
addi x5, x5, 1      			#used for comparison

find:               			#used for n-1    (n)(n-1) ... 2
   addi x2, x2, -1
   add x3, x0, x4   			#copy contents of x4 in x3
   j multiply

done:                			#checks if the factorial is found
   bne x2, x1, find
   j stop

add x4, x4, x3


multiply:           			#used for repeated additions, checks if multiplication is completed
   add x7, x0, x2

multiply1:         			    #used for repeated additions
   addi x7, x7, -1
   add x4, x4, x3
   bne x7, x5, multiply1
   j done
   
negative_and_zero:              #exception handler
   addi x4, x0, 1   			#give factorial of negative numbers =  1
   j stop
two:
   addi x4, x0, 2
stop:
   j stop
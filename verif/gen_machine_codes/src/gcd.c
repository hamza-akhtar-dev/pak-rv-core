int main(void) {
   // declare some variables
   int  x = 32, y = 12, gcd = 0;  
  
   // Loop for GCD evaluation
   while(x != y)
   {
       if(x > y)
           x = x - y;
       else
           y = y - x;
   }
  
   gcd = x;

   // endless loop
   while(1){}
}
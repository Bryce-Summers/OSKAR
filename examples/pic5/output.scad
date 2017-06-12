//  OpenScad code generated from OSKAR python.
//  OSKAR Compiler written by Bryce Summers for Larry Cuba
//  Compiled on June 12, 2017
$fn=130;
$vpr = [0, 0, 0];   // vpr system variable
$vpd = 6.0;         // vpd system variable
$vpt = [0, 0, 0];   // vpt system variable


function modulo(dividend, divisor) =
   dividend % divisor;

// return 0, divisor, 2*divisor, etc based on which interval x is in.
function step(x, divisor) = 
    floor(x/divisor)*divisor;

module floor()
{
   Global_t = $t;
   steps = 1;
   step_size = 1.0/steps;
   // Iteration from 0 to 1 in 1 equal steps.
   for (i=[0:step_size:1])
   {
      translate([-.5, -.5, -.05])
      scale([2, 2, .02])
      color([1, 1, 1, 1])
      cube();
   }
}
module cosine()
{
   Global_t = $t;
   steps = 80;
   step_size = 1.0/steps;
   // Iteration from 0 to 1 in 80 equal steps.
   for (i=[0:step_size:1])
   {
      translate([0, .5, 0])
      scale([1, .5, 1])
      translate([i, cos ( ( i * 360 ) + ( Global_t * 360 ) ), .05])
      scale([.5, 4, 5])
      scale([.0125, .02, .02])
      color([1, 1, 1, 1])
      cube();
   }
}
module draw()
{
      floor();
      cosine();
}

// Draw the root module.
translate([0, 0, 0])rotate([-58,-20, -15]) //set POV
draw();
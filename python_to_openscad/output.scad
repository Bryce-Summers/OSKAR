//  OpenScad code generated from OSKAR python.
//  OSKAR Compiler written by Bryce Summers for Larry Cuba
$fn=130;
$vpr = [0, 0, 0];   // vpr system variable
$vpd = 6.0;         // vpd system variable
$vpt = [0, 0, 0];   // vpt system variable


function myTY1(x, time) = 
   cos((x*360)+(time*360));
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
      translate([i, myTY1 ( i, Global_t ) , .05])
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
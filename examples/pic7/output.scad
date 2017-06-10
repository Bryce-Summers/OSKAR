//  OpenScad code generated from OSKAR python.
//  OSKAR Compiler written by Bryce Summers for Larry Cuba
//  Compiled on June 10, 2017
$fn=130;
$vpr = [0, 0, 0];   // vpr system variable
$vpd = 6.0;         // vpd system variable
$vpt = [0, 0, 0];   // vpt system variable


function modulo(dividend, divisor) =
   dividend % divisor;

function step(dividend, divisor) = 
   floor(dividend, divisor);

function myTY1(x, time) = 
   cos((x*360)+(time*360));

module funplot(TYfunction)
{
   Global_t = $t;
   steps = 80;
   step_size = 1.0/steps;
   // Iteration from 0 to 1 in 80 equal steps.
   for (i=[0:step_size:1])
   {
      translate([0, .5, 0])
      scale([1, .5, 1])
      translate([i, TYfunction ( i , Global_t ), .05])
      scale([.5, 4, 5])
      scale([.0125, .02, .02])
      color([1, 1, 1, 1])
      cube();
   }
}
module cosine()
{
   funplot_myTY1();
}
module funplot_myTY1()
{
   Global_t = $t;
   steps = 80;
   step_size = 1.0/steps;
   // Iteration from 0 to 1 in 80 equal steps.
   for (i=[0:step_size:1])
   {
      translate([0, .5, 0])
      scale([1, .5, 1])
      translate([i, myTY1 ( i , Global_t ), .05])
      scale([.5, 4, 5])
      scale([.0125, .02, .02])
      color([1, 1, 1, 1])
      cube();
   }
}
module MakeArray(base=cube, rows=4, cols=2)
{
   Global_t = $t;
   steps = 80;
   step_size = 1.0/steps;
   // Iteration from 0 to 1 in 80 equal steps.
   for (i=[0:step_size:1])
   {
      translate([modulo ( i , cols ), step ( i , rows ), 0])
      scale([1 / ( rows * cols ), 1 / ( rows * cols ), 1 / ( rows * cols )])
      color([1, 1, 1, 1])
      base();
   }
}
module wallpaper()
{
   MakeArray_cosine(4, 4);
}
module MakeArray_cosine( rows=4,  cols=2)
{
   Global_t = $t;
   steps = 80;
   step_size = 1.0/steps;
   // Iteration from 0 to 1 in 80 equal steps.
   for (i=[0:step_size:1])
   {
      translate([modulo ( i , cols ), step ( i , rows ), 0])
      scale([1 / ( rows * cols ), 1 / ( rows * cols ), 1 / ( rows * cols )])
      color([1, 1, 1, 1])
      cosine();
   }
}
module draw()
{
      wallpaper();
}

// Draw the root module.
translate([0, 0, 0])rotate([-58,-20, -15]) //set POV
draw();
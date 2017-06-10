//  OpenScad code generated from OSKAR python.
//  OSKAR Compiler written by Bryce Summers for Larry Cuba
$fn=130;
$vpr = [0, 0, 0];   // vpr system variable
$vpd = 6.0;         // vpd system variable
$vpt = [0, 0, 0];   // vpt system variable


module floor()
{
   Global_t = $t;
   begin = 0;
   end   = 1;
   // Iteration from [begin,end)
   for (i=[begin:end - 1])
   {
      translate([-.5, -.5, -.05])
      scale([2, 2, .02])
      color([1, 1, 1, 1])
      cube();
   }
}

module row()
{
   Global_t = $t;
   begin = 0;
   end   = 20;
   // Iteration from [begin,end)
   for (i=[begin:end - 1])
   {
      translate([0, 0, .05])
      translate([0, i * .05, 0])
      rotate([0, ( i * 9 ) + ( Global_t * 360 ), 0])
      scale([.1, .025, .1])
      translate([-.5, -.5, -.5])
      color([1, 1, 1, 1])
      cube();
   }
}

module grid()
{
   Global_t = $t;
   begin = 0;
   end   = 7;
   // Iteration from [begin,end)
   for (j=[begin:end - 1])
   {
      translate([j * .11, 0, 0])
      color([1, 1, 1, 1])
      row();
   }
}

module wheel()
{
   Global_t = $t;
   begin = 0;
   end   = 10;
   // Iteration from [begin,end)
   for (k=[begin:end - 1])
   {
      translate([.5, 0, .05])
      rotate([0, k * 20, 0])
      translate([-1, 0, -.05])
      color([1, 1, 1, 1])
      grid();
   }
}

module wheel_0()
{
   Global_t = $t;
   begin = 0;
   end   = 20;
   // Iteration from [begin,end)
   for (i=[begin:end - 1])
   {
      translate([0, 0, .05])
      translate([0, i * .05, 0])
      rotate([0, ( i * 9 ) + ( Global_t * 360 ), 0])
      scale([.1, .025, .1])
      translate([-.5, -.5, -.5])
      color([1, 1, 1, 1])
      cube();
   }
}

module wheel_1()
{
   Global_t = $t;
   begin = 0;
   end   = 7;
   // Iteration from [begin,end)
   for (j=[begin:end - 1])
   {
      translate([j * .11, 0, 0])
      color([1, 1, 1, 1])
      wheel_0();
   }
}

module wheel()
{
   Global_t = $t;
   begin = 0;
   end   = 10;
   // Iteration from [begin,end)
   for (k=[begin:end - 1])
   {
      translate([.5, 0, .05])
      rotate([0, k * 20, 0])
      translate([-1, 0, -.05])
      color([1, 1, 1, 1])
      wheel_1();
   }
}

module draw()
{
      floor();
      row();
}

module draw()
{
      floor();
      grid();
}

module draw()
{
      floor();
      wheel();
}

module draw()
{
      floor();
      wheel();
}

module draw()
{
      floor();
      wheel();
}

// Draw the root module.
translate([0, 0, 0])rotate([-58,-20, -15]) //set POV
draw();
# OSKAR
A compiler for the OSKAR programmatic animation language targeting Python.

Written by Bryce Summers for Larry Cuba.

# Work Diagram
![OSKAR work diagram image.](https://github.com/Bryce-Summers/OSKAR/blob/master/images/work_diagram.png "OSKAR work plan.")

# Usage
Here is the current usage. It is somewhat non-user friendly, which will be remedied in time.

1. Put your desired OSKAR (.osk) file in the oskar_src_files/ folder. Please name it "input.osk"

2. Enter the oskar_to_python folder in a terminal window. Run: `runhaskell oskar_compiler.hs`
Note: this needs the Haskell programming language installed to run.

3. Go to the python_to_openscad/ folder and run the newly generated output.py file. On my windows machine I can simply double click on it and it runs. (In the future, I would like to retool it such that the user simply clicks on the appropriate generator, rather than this way.)

4. You should now see an OpenSCAD file called "output.scad" Try running it and hopefully you will see your desired output.

# Error Messages.
Error messages are now working, which output a likely cause of the error along with the line and column numbers that the errors occured at.

TODO:
 - Give each picture definition a local time. They get passed down through the tree of functions.
 - Every picture definition has an iteration variable (i -> 'which') and a local time variable ('t' -> when)
 - make some small changes to my Python Generator to have the generators run the output file from the OSKAR compiler, rather than the other way around.
 - Upgrade compiler to OSKAR example spec v2.
 - comment my compiler code, so it is easier for readers to know what is going on.
 - Continue to detect and report more errors.


 - Work on error detection when a user messes up the 
 picture[][][] syntax.
# OSKAR
A compiler for the OSKAR programmatic animation language targeting Python.

Written by Bryce Summers for Larry Cuba.

# Work Diagram
![OSKAR work diagram image.](https://github.com/Bryce-Summers/OSKAR/blob/master/images/work_diagram.png "OSKAR work plan.")

# Usage
Here is the current usage. It is somewhat non-user friendly, which will be remedied in time.

1. Put your desired OSKAR (.osk) file in the oskar_src_files/ folder. Please name it "input.osk"

2. Enter the oskar_to_python folder in a terminal window. Run:
```
runhaskell oskar_compiler.hs
```
Note: this needs the Haskell programming language installed to run.

3. Go to the python_to_openscad/ folder and run the newly generated output.py file. On my windows machine I can simply double click on it and it runs. (In the future, I would like to retool it such that the user simply clicks on the appropriate generator, rather than this way.)

4. You should now see an OpenSCAD file called "output.scad" Try running it and hopefully you will see your desired output.
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
The OSKAR compiler outputs (File, line number, Column number) error messages for certain types of syntax or type errors. Please let me know if you try to compile a malformed OSKAR file and an appropriate error message is not displayed.


# Sublime.
Evidently if you are using Sublime, you may be able to press ctrl + b to build and run the Haskell compiler straight from within the text editor.

# ASSUMPTIONS.
Make sure to use spaces instead of tabs in your code. I have yet
to take the liberty of ignoring tabs.

# Debugging the compiler.
The GHCi allows for setting break points like :break function name. This is very helpful.

Use GHCi for debugging.
:set -fbreak-on-error --enables break points at errors and 
                        interrupt points.
:trace main
'Ctrl + C' while program is running.
:history -- lists where the program was currently running at.
:back    -- find out where the loop was located.

TODO:
 - Give each picture definition a local time. They get passed down through the tree of functions.
 - Every picture definition has an iteration variable (i -> 'which') and a local time variable ('t' -> when)
 - make some small changes to my Python Generator to have the generators run the output file from the OSKAR compiler, rather than the other way around.
 - Upgrade compiler to OSKAR example spec v2.
 - comment my compiler code, so it is easier for readers to know what is going on.
 - Continue to detect and report more errors.
 - 3 - 3 - 2017: Parse Picture functions.
 - Detect potential uncommented lines, when non-special english words start showing up.
 - Check to see how 3-valued functions are to be used.

-- FIXME: We may decide to just terminate scalar functions with a ';' character, it would be easier.
parseUntilDefinition :: [[String]] -> ([[String]], [[String]])


 - Work on error detection when a user messes up the 
 picture[][][] syntax.


 #log
 4.21.2017: I was glad to find that the compiler caught a missing right ']' bracket for me.

 5.15.2017: 
  - I'm not sure if I should allow variable names in the iteration counts. {80} is fine, by {numpix} is not currently supported.
  - I'm allowing scaling by scalars via *(s), which no longer requires 3 entries.
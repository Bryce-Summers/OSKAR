"""
This file specifies a generator that takes output from the OSKAR compiler
and converts it into runnable OpenSCAD code.

This file was written by Bryce Summers for Larry Cuba on:
1 - 22 - 2017.

This file was inspired by a similar one written by Larry.
"""

class Scene:

    def __init__(self):
        self.filePath = ".\\"
        self.fileName = self.filePath + "\\output.scad"

        self.pictures = [] # List of Pictures, each of which specifies an OpenSCAD module.
        self.current_picture = None


    def newPicture(self, name):

        self.finishLastPicture()       
        self.current_picture = Picture(name)
        self.pictures.append(self.current_picture)

    def newDrawCommand(self, name):
        
        self.finishLastPicture()
        self.current_picture = Picture(name)
        self.current_picture.make_draw_command()
        self.pictures.append(self.current_picture)

    """
    Currently we implement picture generation by routing all
    of these calls to the latest picture.
    """

    # string, int, int
    # for(int var = begin; var < end; var++)
    def iterations(self, var, begin, end):
        self.current_picture.iterations(var, begin, end)


    # string, string, string
    def scaling(self, sx, sy, sz):
        self.current_picture.scaling(sx, sy, sz)


    def translation(self, tx, ty, tz):
        self.current_picture.translation(tx, ty, tz)


    def rotation(self, rx, ry, rz):
        self.current_picture.rotation(rx, ry, rz)


    def basis(self, name):
        self.current_picture.basis(name)


    def color(self, r, g, b, a):
        self.current_picture.color(r, g, b, a)


    # Complete the definition for the last picture that was defined.
    def finishLastPicture(self):
        if self.current_picture is not None:

            # Since the current OSKAR specification does not
            # mention colors, we specify defaault grey colors
            # here.
            self.current_picture.finish()


    def generateCode(self):
        self.finishLastPicture()
        
        # List of Strings representing lines of code.
        output = []
        self.generateHeader(output)

        for picture in self.pictures:
            picture.generateCode(output)

        # Append the final draw Command.
        last_picture = self.pictures[len(self.pictures) - 1]
        name = last_picture.getName()
        output.append("// Draw the root module.")
        output.append("translate([0, 0, 0])rotate([-58,-20, -15]) //set POV")
        output.append(name + "();")


        # Join the list of strings with a newLine character.
        fileText = "\n".join(output)

        print (fileText)

        self.sendToFile(self.fileName, fileText)


    # Appends a list of strings to the given String[] output object.
    def generateHeader(self, output):

        output.append("//  OpenScad code generated from OSKAR python.")
        output.append("//  OSKAR Compiler written by Bryce Summers for Larry Cuba")
        output.append("$fn=130;")
        output.append("$vpr = [0, 0, 0];   // vpr system variable")
        output.append("$vpd = 6.0;         // vpd system variable")
        output.append("$vpt = [0, 0, 0];   // vpt system variable")
        output.append("\n")

    def sendToFile(self, fileName, fileText):
        file = open(fileName,"w")
        file.write(fileText)
        file.close()


class Picture:

    def __init__(self, name_in):
        self.text = []
        self.myName = name_in
        self.name(name_in)

        # We keep a list of transforms, because OpenSCAD insists on
        # having their transforms specified in funky reverse order.
        self.transforms = []

        # 3 space and 6 space indents.
        self.indent1 = "   "
        self.indent2 = self.indent1*2

        self.isDrawCommand = False

    def make_draw_command(self):
        self.isDrawCommand = True;

    def name(self, name):
        self.text.append("module " + name + "()")
        self.text.append("{")

    def getName(self):
        return self.myName

    # string, int, int
    # for(int var = begin; var < end; var++)
    def iterations(self, var, begin, end):

        # Openscad does not support programmatic time specification.
        if self.isDrawCommand:
            return

        self.text.append(self.indent1 + "Global_t = $t;")
        self.text.append(self.indent1 + "begin = " + str(begin) + ";")
        self.text.append(self.indent1 + "end   = " + str(end) + ";")        
        self.text.append(self.indent1 + "// Iteration from [begin,end)")
        self.text.append(self.indent1 + "for (" + var + "=[begin:end - 1])")
        self.text.append(self.indent1 + "{")


    # string, string, string
    def scaling(self, sx, sy, sz):
        self.transforms.append(self.indent2 + "scale([" + sx + ", " + sy + ", " + sz + "])")


    def translation(self, tx, ty, tz):
        self.transforms.append(self.indent2 + "translate([" + tx + ", " + ty + ", " + tz + "])")

    def rotation(self, rx, ry, rz):
        self.transforms.append(self.indent2 + "rotate([" + rx + ", " + ry + ", " + rz + "])")

    def color(self, r, g, b, a):
        
        # Avoid cluttering the draw commands.
        if self.isDrawCommand:
            return

        self.text.append(self.indent2 + "color([" + r + ", " + g + ", " + b + ", " + a + "])")

    def basis(self, name):
        self._reversePushTransforms()
        self.color("1", "1", "1", "1")
        self.text.append(self.indent2 + name + "();")

    # Here we reverse the order of the transforms from the original C*B*A*[] order,
    # which is the order that a person would left multiply matrices.
    # to the funky reverse ordering of OpenSCAD.
    def _reversePushTransforms(self):
        while len(self.transforms) > 0:
            self.text.append(self.transforms.pop())

    def finish(self):
        if not self.isDrawCommand:
            self.text.append(self.indent1 + "}")
        self.text.append("}\n")

    # Returns a string representing the OpenSCAD code for 
    # this picture definition.
    def generateCode(self, output):
        output += self.text

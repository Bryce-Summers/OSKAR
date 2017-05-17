"""
This file specifies a generator that takes output from the OSKAR compiler
and converts it into runnable OpenSCAD code.

This file was written by Bryce Summers for Larry Cuba on:
1 - 22 - 2017.

This file was inspired by a similar one written by Larry.

If the interface is maintained, this generator may easily be substituted for one that targets a language other than OpenSCAD.
For instance, OpenGL or WebGl could be targeted.
"""

class Scene:

    def __init__(self):
        self.filePath = ".\\"
        self.fileName = self.filePath + "\\output.scad"


        # FIXME: Please renamed these to objects, instead of pictures.
        # These data structures represent all of the generation objects.

        self.pictures = [] # List of Pictures, each of which specifies an OpenSCAD module.
        self.current_picture = None # The current object that this generator is specifying.


    def newPicture(self, name):

        self.finishLastPicture()       
        self.current_picture = Picture(name)
        self.current_picture.make_normal_picture()
        self.pictures.append(self.current_picture)

    def newDirectPicture(self, name):

        self.finishLastPicture()       
        self.current_picture = Picture(name)
        self.current_picture.make_direct_picture()
        self.pictures.append(self.current_picture)


    def newDrawCommand(self, name):
        
        self.finishLastPicture()
        self.current_picture = Picture(name)
        self.current_picture.make_draw_command()
        self.pictures.append(self.current_picture)

    def newFunction(self, name):
        self.finishLastPicture()
        self.current_picture = Function(name)
        self.pictures.append(self.current_picture)
        return self.current_picture



    """
    Currently we implement picture generation by routing all
    of these calls to the latest picture.
    """
    def addArgument(self, arg):
        self.current_picture.addArgument(arg)

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

    def expression(self, txt):
        self.current_picture.expression(txt)


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

# Pictures gradually build their OpenScad text as they are called through a genaricized interface.
class Picture:

    def __init__(self, name_in):
        self.text = []
        self.myName = name_in

        self.name_created = False

        # Name is set later, when we have the full list of arguments.
        #self.name(name_in)

        self.arguments = []

        # We keep a list of transforms, because OpenSCAD insists on
        # having their transforms specified in funky reverse order.
        self.transforms = []

        # 3 space and 6 space indents.
        self.indent1 = "   "
        self.indent2 = self.indent1*2

        self.isDrawCommand   = False
        self.isNormalPicture = False
        self.isDirectPicture = False # Picture Reduction.

    def make_normal_picture(self):
        self.isNormalPicture = True

    def make_draw_command(self):
        self.isDrawCommand = True

    def make_direct_picture(self):
        self.isDirectPicture = True

    def name(self, name, arguments):

        str = "module " + name + "("

        for i in range(len(arguments) - 1):
            str += arguments[i] + ", "
        if len(arguments) > 0:
            str += arguments[len(arguments) - 1]
        str += ")"

        self.text.append(str)
        self.text.append("{")

    # add an arugment name.
    def addArgument(self, arg):
        self.arguments.append(arg)

    def getName(self):
        return self.myName

    # string, int, int
    # for(int var = begin; var < end; var++)
    def iterations(self, var, begin, end):

        self.name(self.myName, self.arguments)

        # Openscad does not support programmatic time specification.
        if self.isDrawCommand:
            return

        # Assuming we always go from 0 to 1 with end steps...
        #step = 1.0 / end # As of 5.15.17, we no longer do this and we use strings now.

        self.text.append(self.indent1 + "Global_t = $t;")
        #self.text.append(self.indent1 + "begin = 0;")
        self.text.append(self.indent1 + "steps = " + str(end) + ";")
        self.text.append(self.indent1 + "step_size = 1.0/steps;")
        #self.text.append(self.indent1 + "end   = 1;")
        self.text.append(self.indent1 + "// Iteration from 0 to 1 in " + str(end) + " equal steps.")
        self.text.append(self.indent1 + "for (" + var + "=[0:step_size:1])")
        self.text.append(self.indent1 + "{")

    def expression(self, txt):
        # Create the header if it doesn't yet exist.
        if not self.name_created:
            self.name(self.myName, self.arguments)
        self.text.append(txt + ";")

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
        # Closing brace for end of iteration loop in normal picture definitions.
        if self.isNormalPicture:
            self.text.append(self.indent1 + "}")
        self.text.append("}\n")

    # Returns a string representing the OpenSCAD code for 
    # this picture definition.
    def generateCode(self, output):
        output += self.text


class Function:

    def __init__(self, name_in):
        self.myName = name_in

        self.args = []        # Strin[]
                              # A list of argument variable names.
        self.expressions = [] # String[]
                              # A list of evaluation expressions for every dimension.

        self.scalar = False   # This stores whether this is a scalar function.
        self.vector = False   # This stores whether this is a vector function.

        self.transforms = []

    # Return Types of functions.
    def scalar_type(self):
        self.scalar = True

    def vector_type(self):
        self.vector = True

    # Names of inputs variables.
    # String[] -> ()
    def addArgument(self, arg):
        self.args.append(arg)

    # String ->
    def addExpression(self, exp):
        self.expressions.append(exp)

    # Finishes this object.
    def finish(self):
        return

    # Returns a string representing the OpenSCAD code for 
    # this picture definition.
    # ASSUMPTION: finish() has been called to finish this picture.
    def generateCode(self, output):

        # Code String, complete with line breaks.
        out = ""

        # 3 space and 6 space indents.
        self.indent1 = "   "
        self.indent2 = self.indent1*2


        # Header.
        out += "function "

        # function name
        out += self.myName + "("

        # Arguments.
        for i in range(0, len(self.args) - 1):
            out += self.args[i] + ", "
        out += self.args[len(self.args) - 1]
        out += ") = \n"

        out += self.indent1

        # If this is a scalar function, then we are done.
        if(self.scalar):
            out += self.expressions[0] + ";"
            output.append(out)
            return

        if(self.vector):
            # Vector functions.
            out += "["
            for i in range (0, len(self.expressions) - 1):
                out += self.expressions[i] + ", "
            out += self.expressions[len(self.expressions) - 1]
            out += "];\n"
            
            output.append(out)
            return


"""
Macrosubstitution code.
Written by Bryce Summers beginning on May.15.217

This code is necessary for getting around Open Scad's non-support for 1st class functions.
"""

class SubstitutableText:

    # String, String[], String.
    # name of function,
    # names of local variables passed into the function.
    # Textual body that makes up the original function in a file.
    # If a language allows 1st class functions, the body would be the final
    # form of the function.
    # In lanauges without 1st class functions, like Openscad,
    # we will perform macrosubstitution on this body.
    def __init__(self, name, arguments, body):
        self.myName = name
        self.myArgs = arguments
        self.myText = body

    def getName(self):
        return self.myName

    def getArgs(self):
        return self.myArgs

    # Used at the end to retrieve the body, which may be written out to a file.
    def getBody(self):
        return self.myBody

    # Returns a Substitutable text object equivalent to
    # replacing the body substituting
    # the find string for the replace string.
    # The inputs are two index associated lists that
    # allow for several macrosubstitutions to be done at once.
    # String[], String[]
    def macroSubstitute(self, finds, replaces):

        # The name is constructed by adding the macrosubstituted argument underscored in.
        name = self.getName()
        for str in replaces:
            name = name + "_" + str

        # Construct the argument list, minus the arguments that are to be
        # directly macrosubstituted into the text.
        old_args = self.getArgs()
        finds_set = set(finds)
        new_args = []
        for arg in old_args
            if arg not in finds_set
                new_args.append(arg)

        # Create the new body by replacing all instances of find with replace.
        new_body = self.getBody()
        for index in range(len(finds))
            find_str    = finds[index]
            replace_str = replaces[index]
            new_body    = new_body.replace(find_str, replace_str)

        return SubstitutableText(name, new_args, new_body)

    # If the other substitution text's body contains a reference to
    # this substitution text...
    # returns the index of the '('.
    # returns -1 if not found.
    def isInsideOtherSubtext(self, other):
        str = other.getBody()

        # Returns True if the name is found, it is followed by a '('
        # and preceded by a space or the beginning of string.
        name_index = str.find(self.myName)
        end_index = name_index + len(self.myName)

        name_found = (name_index > -1)

        if not name_found
            return -1

        followed_by_leftp = (str[end_index] == ')')
        preceded_by_space = name_index == 0 or str[name_index - 1] == ' '

        if name_found and followed_by_leftp and preceded_by_space
            return name_index

        # function name not found.
        return -1

class MacroSubstitutor:

    def __init__(self):

        self.functions = []
        self.func_name_set = set()

    # Using a Trampoline, macrosubstitute all function calls
    # down the entire necessary call chain.
    def addSubstitutionText(self, subText):
        subbed_funcs = [subText]

        # Trampoline.
        while(len(subbed_funcs) > 0):
            func = subbed_funcs.pop()
            new_funcs = self.addSubstitutionText_helper(func)
            for new_func in new_funcs
                subbed_funcs.append(new_funcs)

    # Called every time a new function is created.
    def addSubstitutionText_helper(self, subText):

        subbed_funcs = []

        for func in self.functions
            leftP_index = func.isInsideOtherSubtext(subText)
            if leftP_index < 0
                continue

            # At this point,
            # the new substitution text contains a reference call to 'func'
            # We need to check its arguments and if one of them is a function name,
            # we apply macrosubstitution.
            # FIXME: What about local variables?
            args = parseArguments(subText.getBody(), leftP_index)

            # Pre-existing candidate function that may need to be macro-replaced.
            func_name = func.getName()

            # We will map certain arguments to func to the new function names,
            # then we will delete them.
            #
            # For Example:
            # func:  g(f, x) = f(x)
            #
            # h: h(x) = x + 2
            # subText: foo = g(h, 5)
            #
            # Generated Macrosubstituted function:
            # g_h(x) = h(x)
            # Altered definition of foo:
            # foo = g_h(5)
            finds    = []
            replaces = []





            # We need the indices, because we know the replaced value in the calling, but not
            # the local variable in the called function. Instead we know the index.
            # We'll need to look up an array of the arguments in the called function
            # or pass indices to the SubstitutableText objects.




            # FIXME: Do we want a mapping object or just immediately separate things into
            # finds[] and replaces[]

            for var_name in args:
                if var_name in self.func_name_set:
                    finds.append()

            subbed_func = macrosubstitute(func, mapping)
            subbed_funcs.append(subbed_func)

            # modify the calling function in preparation for the next
            # iteration of the loop and the potential for more
            # substitutions.
            modifySubbedCallingFuntion(subText, mapping)

        # The subbed functions are then macrosubstituted via the trampoline
        # in self.addSubstitutionText()
        return subbed_funcs


    # String, Integer --> returns a list of argument names.
    # Text to be parsed, index of original left parens.
    def parseArguments(self, body, leftP_index):
        output = []
        # Parse from '(' to ')', then separate arguments by ',' after removing ' ' spaces.
        in_count = 1

        # Index of first character after the first '('
        index = leftP_index
        arg_start_index = index + 1
        while(in_count > 0):
            index++

            char = body[index]
            if char == '(':
                in_count++
                continue
            elif char == ')':
                in_count--

            if char == ',' or char == ')':
                # [inclusive, exclusive)
                arg_str = body[arg_start_index:index]
                output.append(arg_str)
                arg_start_index = index + 1

        return output





    # SubstitutionText Object, mapping datastructure (TBD)
    # function naming is name_1stPassedFuncName_2ndPassedFuncName_3rdPassedFuncName_etc
    # This will be consistent across macrosubstitution calls, because of the determined
    # order of arguments. If the same functions are passed as arguments to the same
    # macrosubstitution functor, then they will produce the same named macrosubstituted function,
    # which means that we might want to store a set of all names, to avoid naming conflicts
    # and route identical functor evaluations to the same strings to avoid combinatorial explosion.
    # We also might need to worry about user inputs of names like foo_bar, if there is also
    # a function called foo, where the user passes in bar.
    def macrosubstitute(self, func, mapping):

    # Modify the calling function by removing function variable passed values.
    def modifySubbedCallingFuntion(subText, mapping):



    def unit_tests():
        str = 'foo(a, bb, ccc, dd, e)'

        args = self.parseArguments(str, 3)

        assert(len(args) == 5)
        assert(args[0] == "a")
        assert(args[1] == "bb")
        assert(args[2] == "ccc")
        assert(args[3] == "dd")
        assert(args[4] == "e")

macro = new MacroSubstitutor()
macro.unit_tests()
main = do  
        contents_io <- readFile "../oskar_src_files/ex1.osk"
        -- Once we go into pure functional land, we no longer
        -- use the imperative monads, so we go into a let statement.
        let contents = contents_io
            --line = lineReconstructor contents False
            tokens      = tokenizeString contents
            syntax_tree = parseSyntaxTree tokens
            output      = generatePython syntax_tree

            (picture1, tokens1)          = parsePicture tokens
            (picture2, tokens2)          = parsePicture tokens1
            (picture3, tokens3)          = parsePicture tokens2
            (picture4, tokens4)          = parsePicture tokens3
            (Just drawCommand1, tokens5) = parseDrawCommand tokens4
            (Just drawCommand2, tokens6) = parseDrawCommand tokens5
            (Just drawCommand3, tokens7) = parseDrawCommand tokens6
            (Just drawCommand4, tokens8) = parseDrawCommand tokens7
            (picture5, tokens9)          = parsePicture tokens8
            (Just drawCommand5, tokens10)= parseDrawCommand tokens9
        writeFile "tokens.txt" (unlines tokens)
        writeFile "tokens_after_picture.txt" (unlines tokens10)
        writeFile "output.py" (unlines output)
        --print tokens

--This seems kind of useless to me.
--Removes all junk, such as new line characters, places a ; at the end of every line.
lineReconstructor :: [Char] -> [Char]
lineReconstructor [] = []
lineReconstructor ('\n':rest) = ';' : lineReconstructor rest
lineReconstructor (a:rest) = a : lineReconstructor rest

-- Splits up an input string into atomic syntactic parts.
-- Input String, (reading_comment, reading_token)
tokenizeString :: String -> [String]
tokenizeString input = tokenize input (False, False)

tokenize :: String -> (Bool, Bool) -> [String]
-- base case, return the empty end of list.
tokenize [] (_, True)    = []:[]
tokenize [] (_, False)   = []
-- If we see a new line character and we have been reading a token, then we conclude it with an end of list. (End of String.)
tokenize ('\n':xs) (_, True)  = [] : tokenize xs (False, False)
-- If we are not reading a token and come across a new line, then we just ignore it.
tokenize ('\n':xs) (_, False) = tokenize xs (False, False)

{-|
--- The following lines of code implement tokenization that generates comment tokens.
-- For comments, we just continue to push all characters into a list.
tokenize (x:xs) (True, _)     = let rest_of_comment:rest_of_tokens = tokenize xs (True, True)
                              in (x:rest_of_comment):rest_of_tokens
-- Start of a commment, End of token.
tokenize ('#':xs) (_, True)   = let rest_of_comment:rest_of_tokens = tokenize xs (True, True)
                              in []:('#':rest_of_comment):rest_of_tokens
-- Start of a comment, without ending a token.
tokenize ('#':xs) (_, False)  = let rest_of_comment:rest_of_tokens = tokenize xs (True, True)
                              in ('#':rest_of_comment):rest_of_tokens
-}

-- The Following lines implement tokenization that completely ignores comments.
-- FIXME: Perhaps I should make comment peeling its own function.
tokenize (x:xs)   (True, _)  = tokenize xs (True, False)
tokenize ('#':xs) (_, True)  = [] : (tokenize xs (True, False))
tokenize ('#':xs) (_, False) = tokenize xs (True, False)


-- For Simple operators and syntactic symbols, we can directly parse them to tokens.
tokenize (':':':':xs) (_, t) | t == False = symbol : tokenize xs (False, False)
                             | t == True  = [] : symbol : tokenize xs (False, False)
                             where symbol = "::"
tokenize (':':xs) (_, t)     | t == False = symbol : tokenize xs (False, False)
                             | t == True  = [] : symbol : tokenize xs (False, False)
                             where symbol = ":"
tokenize ('<':'<':'<':xs) (_, t) | t == False = symbol : tokenize xs (False, False)
                                 | t == True  = [] : symbol : tokenize xs (False, False)
                                 where symbol = "<<<"
tokenize ('<':'<':xs) (_, t)     | t == False = symbol : tokenize xs (False, False)
                                 | t == True  = [] : symbol : tokenize xs (False, False)
                                 where symbol = "<<"
tokenize (',':xs) (_, t)         | t == False = symbol : tokenize xs (False, False)
                                 | t == True  = [] : symbol : tokenize xs (False, False)
                                 where symbol = ","
tokenize ('=':xs) (_, t)         | t == False = symbol : tokenize xs (False, False)
                                 | t == True  = [] : symbol : tokenize xs (False, False)
                                 where symbol = "="
tokenize ('*':xs) (_, t)         | t == False = symbol : tokenize xs (False, False)
                                 | t == True  = [] : symbol : tokenize xs (False, False)
                                 where symbol = "*"
tokenize ('/':xs) (_, t)         | t == False = symbol : tokenize xs (False, False)
                                 | t == True  = [] : symbol : tokenize xs (False, False)
                                 where symbol = "/"
tokenize ('+':xs) (_, t)         | t == False = symbol : tokenize xs (False, False)
                                 | t == True  = [] : symbol : tokenize xs (False, False)
                                 where symbol = "+"
{-
tokenize ('-':xs) (_, t)         | t == False = symbol : tokenize xs (False, False)
                                 | t == True  = [] : symbol : tokenize xs (False, False)
                                 where symbol = "-"
-}
tokenize ('(':xs) (_, t)         | t == False = symbol : tokenize xs (False, False)
                                 | t == True  = [] : symbol : tokenize xs (False, False)
                                 where symbol = "("
tokenize (')':xs) (_, t)         | t == False = symbol : tokenize xs (False, False)
                                 | t == True  = [] : symbol : tokenize xs (False, False)
                                 where symbol = ")"
tokenize ('[':xs) (_, t)         | t == False = symbol : tokenize xs (False, False)
                                 | t == True  = [] : symbol : tokenize xs (False, False)
                                 where symbol = "["
tokenize (']':xs) (_, t)         | t == False = symbol : tokenize xs (False, False)
                                 | t == True  = [] : symbol : tokenize xs (False, False)
                                 where symbol = "]"
tokenize ('{':xs) (_, t)         | t == False = symbol : tokenize xs (False, False)
                                 | t == True  = [] : symbol : tokenize xs (False, False)
                                 where symbol = "{"
tokenize ('}':xs) (_, t)         | t == False = symbol : tokenize xs (False, False)
                                 | t == True  = [] : symbol : tokenize xs (False, False)
                                 where symbol = "}"
tokenize ('@':xs) (_, t)         | t == False = symbol : tokenize xs (False, False)
                                 | t == True  = [] : symbol : tokenize xs (False, False)
                                 where symbol = "@"

-- End tokens with spaces, but otherwise ignore them.
tokenize (' ':xs) (_, True)      = [] : tokenize xs (False, False)
tokenize (' ':xs) (_, False)     = tokenize xs (False, False)

-- Everything else are names.
tokenize (x:xs) (False, _)       = let rest_of_name:rest_of_tokens = tokenize xs (False, True)
                                   in (x:rest_of_name):rest_of_tokens


-- Here we define the data type for the abstract syntax tree and a healthy collection of lower level types.
data AST = AST {ast_pictures :: [Picture]
               ,ast_drawings :: [DrawCommand]
               } --deriving (Show, Read, Eq)

data Picture = Picture { picture_name  :: String  
                        ,picture_basis :: String           -- The Name of a lower level Picture definition that will be used to form this picture.
                        ,picture_transforms :: [Transform] -- The transforms in order that will be applied to the basis picture for each iteration.
                        ,picture_iterations :: Iteration    -- An iteration object to control the looping.
                       }

data Transform = Transform { transform_species :: Transform_Species
                            ,transform_x :: String
                            ,transform_y :: String
                            ,transform_z :: String
                           } | NULL-- deriving (Show)
data Transform_Species = Translate | Scale | Rotate --deriving (Show, Eq)

data Iteration = Iteration { iteration_variable :: String -- The iteration variable. e.g. 'i', 'j', etc.
                            ,iteration_begin :: Int       -- The iteration this variable will start at.
                            ,iteration_end   :: Int       -- The iteration this variable will end before.
                           }                    -- for variable = begin; variable < end; variable++

data DrawCommand =  DrawCommand { drawCommand_iterations  :: Iteration
                                 , drawCommand_pictures   :: [String]
                                }

--data PictureName = String


-- Show converts the type to a string.
-- read constructs the type from a string.

instance Show Transform_Species where
    show Translate = "Translation"
    show Scale     = "Scale"
    show Rotate    = "Rotate"


-- Converts a list of tokens into an abstract syntax tree.
parseSyntaxTree :: [String] -> AST
parseSyntaxTree tokens =
    _parseSyntaxTree tokens [] []

-- tokens -> Pictures accumulator -> DrawCommands accumulator -> output
_parseSyntaxTree :: [String] -> [Picture] -> [DrawCommand] -> AST
-- Handle Empty List.
_parseSyntaxTree [] pics draws = AST {ast_pictures=pics, ast_drawings=draws}
-- Handle Picture definition.
_parseSyntaxTree (tokens@(name:"<<":rest)) pictures drawCommands = 
    let (picture, rest_of_tokens) = parsePicture tokens
    in  _parseSyntaxTree rest_of_tokens (picture ++ pictures) drawCommands
-- Handle Draw Command.
_parseSyntaxTree tokens pictures drawCommands =
    let (result, rest_of_tokens) = parseDrawCommand tokens
    in  case result of
          Just drawCommand ->
            _parseSyntaxTree rest_of_tokens pictures (drawCommand:drawCommands)
        -- If we encounter a non-parsable region, then we conclude the parsing.
          Nothing -> _parseSyntaxTree [] pictures drawCommands


-- Parses the front of a sequence of tokens into a picture and the remainder of the token list.
parsePicture :: [String] -> ([Picture], [String])
parsePicture (name:"<<":basis_name:rest)   = 
    parseAnonymousPicture name basis_name rest [] 0

-- Labeled name -> basis_name -> Tokens -> Pictures Parsed thus far -> index_of_anonymous_function -> (Pictures parsed, [Rest of Tokens])
parseAnonymousPicture :: String -> String -> [String] -> [Picture] -> Int -> ([Picture], [String])
parseAnonymousPicture name basis_name ("[":rest) pictures index =
    let (tokens, tokens_after_picture) = parseBraket ("[":rest) "[" "]"
        (iterations, transform_tokens) = parseIterations tokens
        (transforms)                   = parseTransforms transform_tokens
    in
    -- Keep parsing from bottom up untill we run out of picture definitions.
        case tokens_after_picture of
            ("[": rest1) -> parseAnonymousPicture
                                        name
                                        anon_name
                                        (tokens_after_picture)
                                        ((Picture {picture_name=anon_name, picture_basis=basis_name, picture_transforms=transforms, picture_iterations=iterations}):pictures)
                                        (index + 1)
            otherwise                -> ((Picture {picture_name=name, picture_basis=basis_name, picture_transforms=transforms, picture_iterations=iterations}):pictures,
                                        tokens_after_picture)
        where anon_name = name ++ "_" ++ (show index)
                                        

-- Converts the front of a sequence of tokens containing the initial scop of the input left and right bracket strings
-- into a set of strings in the front and the set of strings after the parse.
-- Tokens -> left braket -> right braket -> (parsed_tokens, rest_of_the_tokens)
parseBraket :: [String] -> String -> String -> ([String], [String])
-- Reduce to a helper function with a count variable.
parseBraket tokens@(first_token:rest_of_tokens) left_braket right_braket
    | (first_token == left_braket) = _parseBraket rest_of_tokens left_braket right_braket  1
    | (first_token /= left_braket) = ([], tokens) -- The string of brakets is not present at the head of the input string of tokens.

_parseBraket :: [String] -> String -> String -> Int -> ([String], [String])
-- Handle left parentheses.
_parseBraket (token:rest) left_braket right_braket count
-- Left Parens.
    | token == left_braket = 
        let (output_tokens, rest_of_tokens) = _parseBraket rest left_braket right_braket (count + 1)
        in  (output_tokens, rest_of_tokens)
-- Right Parens.
-- We use a 1, because we want To omit the left parens.
    | (token == right_braket) && (count == 1) = ([], rest)
    | (token == right_braket) && (count > 1)  = -- (/=) is the not equal operator.
            let (output_tokens, rest_of_tokens) = _parseBraket rest left_braket right_braket (count - 1)
            in  (right_braket:output_tokens, rest_of_tokens)
    | otherwise =
        let (output_tokens, rest_of_tokens) = _parseBraket rest left_braket right_braket count
        in  (token:output_tokens, rest_of_tokens)



-- Parse the head of a list of tokens to an iteration data structure and the remainder of the tokens.
-- Tokens in -> (Iteration, The rest of the tokens.)
parseIterations :: [String] -> (Iteration, [String])
-- {i:80}
parseIterations ("{":variable_name:":":iteration_count:"}":rest) = 
    (Iteration {iteration_variable=variable_name, iteration_begin=0, iteration_end=(readInt iteration_count)}, rest)
-- {80}
parseIterations ("{":iteration_count:"}":rest) =
    (Iteration {iteration_variable="i", iteration_begin=0, iteration_end=(readInt iteration_count)}, rest)


-- Converts a list of tokens into a list of transforms.
parseTransforms :: [String] -> [Transform]
parseTransforms [] = []
parseTransforms (species:"(":x:",":y:",":z:")":rest) =
    Transform { transform_species=parseTransformSpecies species, transform_x=x, transform_y=y, transform_z=z}:(parseTransforms rest)
-- Otherwise we need to manually parse the contents.    
parseTransforms (species:"(":tokens) = 
    let (x_list, rest1) = parseUntil tokens ","
        (y_list, rest2) = parseUntil rest1  ","
        (z_list, rest3) = parseUntil rest2  ")"
        -- http://stackoverflow.com/questions/9220986/is-there-any-haskell-function-to-concatenate-list-with-separator
        x = unwords x_list
        y = unwords y_list
        z = unwords z_list

    in  Transform { transform_species=parseTransformSpecies species, transform_x=x, transform_y=y, transform_z=z}:(parseTransforms rest3)
parseTransforms other = [NULL]     


-- Tokens_in -> Token searching for -> (tokens peeled off, tokens after searched for string.)
-- Currently, this returns all tokens if the given string is never found.
parseUntil :: [String] -> String -> ([String], [String])
parseUntil [] _ = ([], [])
parseUntil (token:rest) search
    | token == search = ([], rest)
    | token /= search = 
        let (tokens_before, tokens_after) = parseUntil rest search
        in  (token:tokens_before, tokens_after)


parseTransformSpecies :: String -> Transform_Species
parseTransformSpecies "*" = Scale
parseTransformSpecies "+" = Translate
parseTransformSpecies "@" = Rotate


-- Parses the front of a list of tokens
parseDrawCommand :: [String] -> (Maybe DrawCommand, [String])
parseDrawCommand (name:"{":rest) = 
    let (iteration, rest1)        = parseIterations ("{":rest)
        (pictures, rest2)  = parseBraket rest1 "[" "]"
    in  (Just DrawCommand { drawCommand_iterations=iteration, drawCommand_pictures=pictures}, rest2)
parseDrawCommand (name:"[":rest) =
    let iteration = Iteration { iteration_variable = "i", iteration_begin=0, iteration_end=1}
        (pictures, rest1)  = parseBraket ("[":rest) "[" "]"
    in  (Just DrawCommand { drawCommand_iterations=iteration, drawCommand_pictures=pictures}, rest1)
-- No DrawCommand is present here.
parseDrawCommand tokens = (Nothing, tokens)


-- Syntax Generation Commands.

-- Converts an Abstract Syntax tree into a python file in the OSKAR Abstract python generation script.
generatePython :: AST -> [String]
generatePython AST {ast_pictures=pictures, ast_drawings=drawCommands} =
    let accum1 = generateList drawCommands generateDrawCommand []
        accum2 = generateList pictures generatePicture accum1
    in  "\"\"\"\n":
        "Python Generated by OSKAR Compiler\n":
        "Compiler written by Bryce Summers\n":
        "Please see https://github.com/Bryce-Summers/OSKAR\n":
        "\"\"\"\n":
        "#Global Variables\n$t = 0\n\n":
        accum2

-- Converts a list of arbitrary type to strings and appends it 
-- to the fron of the given input string list.
-- input list -> conversion function -> accumulation list -> output
generateList :: [a] -> (a -> String) -> [String] -> [String]
generateList (x:xs) toString accum =
    generateList xs toString ((toString x) : accum)
generateList [] _ accum = accum


generatePicture :: Picture -> String
generatePicture Picture { picture_name       = name
                         ,picture_basis      = basis
                         ,picture_transforms = transforms
                         ,picture_iterations = iterations
                        } =
                let indent = "      "
                in
                    "def " ++ name ++ "():\n" ++
                    generateIteration iterations "   " ++
                    indent ++ "pushState()\n" ++
                    generateTransforms transforms indent ++
                    indent ++ basis ++ "()\n" ++
                    indent ++ "popState()" ++
                    "\n"

-- Iteration to be generated -> indentation string -> output.
generateIteration :: Iteration -> String -> String
generateIteration (Iteration {iteration_variable=var, iteration_begin=begin, iteration_end=end}) indent =
    indent ++
    "for " ++
    var ++
    " in range(" ++
    show begin ++
    ", "  ++
    show end ++
    "):\n"

-- List of transforms to generate -> Indentation String -> output.
generateTransforms :: [Transform] -> String -> String
generateTransforms [] indentation_string = indentation_string ++ "\n"
generateTransforms (Transform{transform_species = species,
                              transform_x = x,
                              transform_y = y,
                              transform_z = z}:rest)
                    indentation_string =
                    indentation_string ++
                    (show species) ++ "(" ++ x ++ ", " ++ y ++ ", " ++ z ++ ")\n" ++
                    (generateTransforms rest indentation_string)
generateTransforms (NULL:rest) indent = indent ++ error_str "Transform was not Parsed" ++ (generateTransforms rest indent)




generateDrawCommand :: DrawCommand -> String
generateDrawCommand drawCommand = "DrawCommand"

{-
data AST = AST {ast_pictures :: [Picture]
               ,ast_drawings :: [DrawCommand]
               } --deriving (Show, Read, Eq)
-}


-- alternately, main = print . map readInt . words =<< readFile "test.txt"
readInt :: String -> Int
readInt = read

error_str :: String -> String
error_str str = "!!! ERROR: " ++ str ++ " !!!\n"
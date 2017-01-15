main = do  
        contents_io <- readFile "../oskar_src_files/ex1.osk"
        -- Once we go into pure functional land, we no longer
        -- use the imperative monads, so we go into a let statement.
        let contents = contents_io
            --line = lineReconstructor contents False
            tokens = tokenizeString contents
            --syntax_tree = parseSyntaxTree tokens
            --output = generate_python syntax_tree
        writeFile "output.txt" (unlines tokens)
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

-- For comments, we just continue to push all characters into a list.
tokenize (x:xs) (True, _)     = let rest_of_comment:rest_of_tokens = tokenize xs (True, True)
                              in (x:rest_of_comment):rest_of_tokens
-- Start of a commment, End of token.
tokenize ('#':xs) (_, True)   = let rest_of_comment:rest_of_tokens = tokenize xs (True, True)
                              in []:('#':rest_of_comment):rest_of_tokens
-- Start of a comment, without ending a token.
tokenize ('#':xs) (_, False)  = let rest_of_comment:rest_of_tokens = tokenize xs (True, True)
                              in ('#':rest_of_comment):rest_of_tokens


-- For Simple operators and syntactic symbols, we can directly parse them to tokens.
tokenize (':':':':xs) (_, t) | t == False = symbol : tokenize xs (False, False)
                             | t == True  = [] : symbol : tokenize xs (False, False)
                             where symbol = "::"
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
tokenize ('-':xs) (_, t)         | t == False = symbol : tokenize xs (False, False)
                                 | t == True  = [] : symbol : tokenize xs (False, False)
                                 where symbol = "-"
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
data AST = Empty | AST {ast_pictures :: [Picture]
                       ,ast_drawings :: [DrawCommand]
                       } --deriving (Show, Read, Eq)

data Picture = Picture { picture_basis :: PictureName           -- The Name of a lower level Picture definition that will be used to form this picture.
                        ,picture_transforms :: [Transform]   -- The transforms in order that will be applied to the basis picture for each iteration.
                        ,picture_iterations :: Iteration         -- An iteration object to control the looping.
                       }

data Transform = Transform { transform_species :: Transform_Species
                            ,transform_x :: String
                            ,transform_y :: String
                            ,transform_z :: String
                           }-- deriving (Show)
data Transform_Species = Translate | Scale | Rotate --deriving (Show, Eq)

data Iteration = Iteration { iteration_variable :: String -- The iteration variable. e.g. 'i', 'j', etc.
                            ,iteration_begin :: Int       -- The iteration this variable will start at.
                            ,iteration_end   :: Int       -- The iteration this variable will end before.
                           }                    -- for variable = begin; variable < end; variable++

data DrawCommand =  DrawCommand { drawCommand_iterations  :: Iteration
                                 , drawCommand_pictures   :: [PictureName]
                                }

data PictureName = String

-- Show converts the type to a string.
-- read constructs the type from a string.

instance Show Transform_Species where
    show Translate = "Translation"
    show Scale     = "Scale"
    show Rotate    = "Rotate"

-- Converts a list of tokens into an abstract syntax tree.
parseSyntaxTree :: [String] -> AST
parseSyntaxTree input = Empty

-- Converts an Abstract Syntax tree into a python file in the OSKAR Abstract python generation script.
generatePython :: AST -> [String]
generatePython input = ["Implement generatePython Please!"]

-- alternately, main = print . map readInt . words =<< readFile "test.txt"
readInt :: String -> Int
readInt = read
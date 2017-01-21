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
                           }-- deriving (Show)
data Transform_Species = Translate | Scale | Rotate --deriving (Show, Eq)

data Iteration = Iteration { iteration_variable :: String -- The iteration variable. e.g. 'i', 'j', etc.
                            ,iteration_begin :: Int       -- The iteration this variable will start at.
                            ,iteration_end   :: Int       -- The iteration this variable will end before.
                           }                    -- for variable = begin; variable < end; variable++

data DrawCommand =  DrawCommand { drawCommand_iterations  :: Iteration
                                 , drawCommand_pictures   :: [String]
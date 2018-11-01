module Main where

import           Lib                (appendEnumeration, enumerateList,
                                     processResponse, tables)
import           System.Environment (getArgs)
import           System.Process     (callProcess)
import           Text.LaTeX         (execLaTeXT, renderFile)

main :: IO ()
main = do
    args <- getArgs
    ls <- mapM processResponse args
    eLTX <- execLaTeXT $ tables $ map appendEnumeration $ enumerateList ls
    renderFile "dictionary.tex" eLTX
    callProcess "xelatex" ["dictionary.tex"]
    return ()

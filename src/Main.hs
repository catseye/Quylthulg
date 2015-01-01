module Main where

import System.Environment
import Qlzqqlzuup

main = do
    args <- getArgs
    case args of
        [fileName] -> do
            c <- readFile fileName
            putStrLn $ showRun c
            return ()
        _ -> do
            putStrLn "Usage: qlzqqlzuup <filename.quylthulg>"

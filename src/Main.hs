module Main where

import System.Environment
import Qlzqqlzuup

main = do
    args <- getArgs
    case args of
        ["-m", fileName] -> do
            c <- readFile fileName
            mrun c
            return ()
        [fileName] -> do
            c <- readFile fileName
            putStrLn $ showRun c
            return ()
        _ -> do
            putStrLn "Usage: qlzqqlzuup [-m] <filename.quylthulg>"

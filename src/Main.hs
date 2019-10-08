module Main where

import System.Environment
import System.Exit
import System.IO

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
            abortWith "Usage: qlzqqlzuup [-m] <filename.quylthulg>"

abortWith msg = do
    hPutStrLn stderr msg
    exitWith (ExitFailure 1)

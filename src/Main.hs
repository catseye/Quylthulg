module Main where

import System.Environment
import Qlzqqlzuup

main = do
    [fileName] <- getArgs
    c <- readFile fileName
    putStr $ showRun c

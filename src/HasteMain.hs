module Main where

import Haste
import Haste.DOM
import Haste.Events

import Qlzqqlzuup

main = withElems ["prog", "result"] driver

driver [progElem, resultElem] = do
    onEvent progElem Change $ \_ -> execute
    where
        execute = do
            Just prog <- getValue progElem
            setProp resultElem "innerHTML" (showRun prog)

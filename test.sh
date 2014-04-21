#!/bin/sh

if [ x`which ghc` = x -a x`which runhugs` = x ]; then
    echo "Neither ghc nor runhugs found on search path"
    exit 1
fi

touch fixture.markdown

if [ ! x`which ghc` = x ]; then
    cat >>fixture.markdown <<EOF
    -> Functionality "Interpret Quylthulg Program" is implemented by
    -> shell command
    -> "ghc src/Qlzqqlzuup.hs -e "do c <- readFile \"%(test-body-file)\"; putStr $ showRun c""

EOF
fi

if [ ! x`which runhugs` = x ]; then
    cat >>fixture.markdown <<EOF
    -> Functionality "Interpret Quylthulg Program" is implemented by
    -> shell command
    -> "runhugs src/Main.hs %(test-body-file)"

EOF
fi

falderal fixture.markdown tests/Quylthulg.markdown
RESULT=$?
rm -f fixture.markdown
exit $RESULT

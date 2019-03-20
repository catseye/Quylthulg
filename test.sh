#!/bin/sh

APPLIANCES=""
if [ -x bin/qlzqqlzuup ]; then
    APPLIANCES="$APPLIANCES tests/appliances/qlzqqlzuup.md"
fi
if command -v runhaskell >/dev/null 2>&1; then
    APPLIANCES="$APPLIANCES tests/appliances/qlzqqlzuup_runhaskell.md"
fi
if [ "${APPLIANCES}x" = x ]; then
    echo "Neither bin/qlzqqlzuup executable nor runhaskell found on search path."
    exit 1
fi
falderal $APPLIANCES tests/Quylthulg.markdown

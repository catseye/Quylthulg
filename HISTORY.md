History of Quylthulg
====================

Version 1.0
-----------

Initial release, 6 December 2008.

Version 1.0 revision 2011.1214
------------------------------

Cosmetic re-packaging.

Version 1.0 revision 2014.0819
------------------------------

General modernization and picking of nits.  Conversion of documentation to
Markdown.  Ensuring reference implementation works with both ghc and Hugs.

Version 1.0 revision 2015.0101
------------------------------

Added build script, example program, and usage message to reference
implementation.

Version 1.0 revision 2016.0504
------------------------------

Fixed embarassing [bug](https://github.com/catseye/Quylthulg/issues/1) in
the reference implementation, reported by [LegionMammal978](https://github.com/LegionMammal978).
The interpreter wasn't able to handle cyclic lists in `foreach` expressions.
Also added several example programs and test cases to help confirm the fix.

Also added `-m` option to the reference implementation, which tells it to
use the monadic interpreter.

Version 1.0 revision 2019.0321
------------------------------

Added a demo of a web-based interpreter, made by compiling Qlzqqlzuup.hs
to Javascript using the Haste compiler, and sticking that into an HTML
page along with some support glue.

Modernized the build system; `bin/qlzqqlzuup` is now a shell script that
runs the compiled executable if it can be found, or tries to run the source
using `runhaskell` if possible, or tries to run the source using `runhugs`
if possible, in that order.

Forgot to update this HISTORY file.

Version 1.0 revision 2019.0326
------------------------------

Changed how Qlzqqlzuup, the Lord of Flesh depicts the final result of
running a Quylthulg program.

Previously, it would simply output the standard derived `show`
representation of its internal Haskell data structure.  It now formats the
result as a literal term in Quylthulg's concrete syntax.

Such terms can be round-tripped: when treated as Quylthulg programs themselves,
they will evaluate to themselves.  (This is true in almost all cases.
Discovering the one case where it is not true is left as an exercise for the
reader.)

This was done to make the output, if not more readable, then more idiomatic
(in some local sense).

Since the language doesn't really define how the result of a Quylthulg
program should be represented, this version number of the language remains
unchanged.

Also fixed a couple of typos in the README.

Version 1.0 revision 2019.1008
------------------------------

The driver script now understands the environment variable `FORCE_HUGS` to
mean you want to run Qlzqqlzuup using Hugs, even if you have `ghc` available.

Simplified and updated Haste driver code and command-line driver code.

Renamed `.markdown` file extensions to `.md`.

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

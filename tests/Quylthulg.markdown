Test Suite for Quylthulg
========================

This test suite is written in the format of Falderal 0.7.  It is far from
exhaustive, but provides a basic sanity check that the language I've designed
here comes close to what I had in mind.

Quylthulg Tests
---------------

    -> Tests for functionality "Interpret Quylthulg Program"

    -> Functionality "Interpret Quylthulg Program" is implemented by
    -> shell command
    -> "bin/qlzqqlzuup %(test-body-file)"

    -> Functionality "Interpret Quylthulg Program" is implemented by
    -> shell command
    -> "bin/qlzqqlzuup -m %(test-body-file)"

Integer expressions.
--------------------

    | 5
    = Int 5

    | +6+9+
    = Int 15

    | +1+*7*-8-1-*+
    = Int 50

String expressions.
-------------------

    | &~$Shoes are $&&~~&~$4.99 a pair$&&
    = Str "Shoes are $4.99 a pair"

List expressions.
-----------------

    | [1,2,3]
    = Cons (Int 1) (Cons (Int 2) (Cons (Int 3) Null))

    | [1,2|3]
    = Cons (Int 1) (Cons (Int 2) (Int 3))

    | <[1,2|3]<abort<
    = Int 1

    | <1<abort<
    = Abort

    | >[1,2|3]>abort>
    = Cons (Int 2) (Int 3)

    | >1>null>
    = Null

    | <,1,2,<null<
    = Int 1

    | >,1,2,>null>
    = Int 2

    | ,1,,2,3,,
    = Cons (Int 1) (Cons (Int 2) (Int 3))

    | ;[1,2];[3];
    = Cons (Int 1) (Cons (Int 2) (Cons (Int 3) Null))

    | ;[1,2];3;
    = Cons (Int 1) (Cons (Int 2) (Int 3))

    | ;null;null;
    = Null

    | ;[1];null;
    = Cons (Int 1) Null

    | ;null;[1];
    = Cons (Int 1) Null

Labels and gotos.
-----------------

    | :A:goto$A$
    = Label "A" (Goto "A")

Foreach expressions.
--------------------

    | foreach $n$=[7,2,3] with $a$=0 be +$a$+$n$+ else be abort
    = Int 12

    | foreach $n$=null with $a$=0 be +$a$+$n$+ else be abort
    = Abort

    | foreach $n$=[1,2,3] with $a$=null be ,$n$,$a$, else be null
    = Cons (Int 3) (Cons (Int 2) (Cons (Int 1) Null))

This is how boolean expressions can be built with `foreach`es.
We take `null` to mean **false** and `[1]` to mean **true**.

Boolean NOT.

    | foreach $n$=null with $a$=null be null else be [1]
    = Cons (Int 1) Null

    | foreach $n$=[1] with $a$=null be null else be [1]
    = Null

Boolean OR.

    | foreach $n$=;[1];[1]; with $a$=[1] be $a$ else be null
    = Cons (Int 1) Null

    | foreach $n$=;null;[1]; with $a$=[1] be $a$ else be null
    = Cons (Int 1) Null

    | foreach $n$=;[1];null; with $a$=[1] be $a$ else be null
    = Cons (Int 1) Null

    | foreach $n$=;null;null; with $a$=[1] be $a$ else be null
    = Null

Boolean AND.

    | foreach $n$=[1] with $a$=[1] be
    |   foreach $m$=$a$ with $b$=null be [1]
    |   else be null
    | else be null
    = Cons (Int 1) Null

    | foreach $n$=null with $a$=[1] be
    |   foreach $m$=$a$ with $b$=null be [1]
    |   else be null
    | else be null
    = Null

    | foreach $n$=[1] with $a$=null be
    |   foreach $m$=$a$ with $b$=null be [1]
    |   else be null
    | else be null
    = Null

    | foreach $n$=null with $a$=null be
    |   foreach $m$=$a$ with $b$=null be [1]
    |   else be null
    | else be null
    = Null

Some list-processing-type things that you often see in functional
programming.

Reverse a list.

    | foreach $x$ = [10, 20, 40, 80]
    |     with $a$ = null be
    |         ,$x$,$a$,
    |     else be
    |         null
    = Cons (Int 80) (Cons (Int 40) (Cons (Int 20) (Cons (Int 10) Null)))

Find the length and the sum of a list of integers.

    | foreach $x$ = [10, 20, 40]
    |     with $a$ = ,0,0, be
    |         ,+<$a$<0<+1+,+>$a$>0>+$x$+,
    |     else be
    |         null
    = Cons (Int 3) (Int 70)

Take the first 3 elements from a list (in reverse order.)

    | foreach $x$ = [10, 20, 40, 80, 60, 10, 30]
    |     with $a$ = ,null,[1,1,1,1], be
    |         foreach $n$=>>$a$>null>>null>
    |             with $r$=99999 be
    |                 ,,$x$,<$a$<null<,,>>$a$>null>>null>,
    |             else be
    |                 abort
    |     else be
    |         null
    = Cons (Cons (Int 40) (Cons (Int 20) (Cons (Int 10) Null))) (Cons (Int 1) Null)

Take the first 5 elements from a cyclic list.

    | foreach $x$ = :L:[10, 20, goto $L$]
    |     with $a$ = ,null,[1,1,1,1,1,1], be
    |         foreach $n$=>>$a$>null>>null>
    |             with $r$=99999 be
    |                 ,,$x$,<$a$<null<,,>>$a$>null>>null>,
    |             else be
    |                 abort
    |     else be
    |         null
    = Cons (Cons (Int 10) (Cons (Int 20) (Cons (Int 10) (Cons (Int 20) (Cons (Int 10) Null))))) (Cons (Int 1) Null)

Macros.
-------

    | {*[Five][5]}{Five}
    = Int 5

    | {*[(A][1]}+{(A}+4+
    = Int 5

    | {*[SQR][*{X}*{X}*]}{*[X][5]}{SQR}
    = Int 25

    | {*[}][This is my comment!]}~${}}$
    = Str "This is my comment!"

    | {*[Dave][3]}{*[Emily][4]}$Number of Macros Defined$
    = Int 2

    | &~${$&~$*[S][T]}$&
    = Str "{*[S][T]}"

    | &~${$&~$S}$&
    = Str "{S}"

    | %&~${$&~$*[S][T]}$&%&~${$&~$S}$&%
    = Str "T"

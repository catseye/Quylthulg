Test Suite for Quylthulg
========================

This test suite is written in the format of Falderal 0.7.  It is far from
exhaustive, but provides a basic sanity check that the language I've designed
here comes close to what I had in mind.

    -> Tests for functionality "Interpret Quylthulg Program"

Integer expressions.
--------------------

    | 5
    = 5

    | +6+9+
    = 15

    | +1+*7*-8-1-*+
    = 50

String expressions.
-------------------

    | ~$Hello, world!$
    = ~$Hello, world!$

    | &~$Shoes are $&&~~&~$4.99 a pair$&&
    = ~"Shoes are $4.99 a pair"

List expressions.
-----------------

    | [1,2,3]
    = [1,2,3]

    | [1,2|3]
    = [1,2|3]

    | <[1,2|3]<abort<
    = 1

    | <1<abort<
    = abort

    | >[1,2|3]>abort>
    = [2|3]

    | >1>null>
    = null

    | <,1,2,<null<
    = 1

    | >,1,2,>null>
    = 2

    | ,1,,2,3,,
    = [1,2|3]

    | ;[1,2];[3];
    = [1,2,3]

    | ;[1,2];3;
    = [1,2|3]

    | ;null;null;
    = null

    | ;[1];null;
    = [1]

    | ;null;[1];
    = [1]

Labels and gotos.
-----------------

    | :A:goto$A$
    = :A:goto $A$

Foreach expressions.
--------------------

    | foreach $n$=[7,2,3] with $a$=0 be +$a$+$n$+ else be abort
    = 12

    | foreach $n$=null with $a$=0 be +$a$+$n$+ else be abort
    = abort

    | foreach $n$=[1,2,3] with $a$=null be ,$n$,$a$, else be null
    = [3,2,1]

This is how boolean expressions can be built with `foreach`es.
We take `null` to mean **false** and `[1]` to mean **true**.

Boolean NOT.

    | foreach $n$=null with $a$=null be null else be [1]
    = [1]

    | foreach $n$=[1] with $a$=null be null else be [1]
    = null

Boolean OR.

    | foreach $n$=;[1];[1]; with $a$=[1] be $a$ else be null
    = [1]

    | foreach $n$=;null;[1]; with $a$=[1] be $a$ else be null
    = [1]

    | foreach $n$=;[1];null; with $a$=[1] be $a$ else be null
    = [1]

    | foreach $n$=;null;null; with $a$=[1] be $a$ else be null
    = null

Boolean AND.

    | foreach $n$=[1] with $a$=[1] be
    |   foreach $m$=$a$ with $b$=null be [1]
    |   else be null
    | else be null
    = [1]

    | foreach $n$=null with $a$=[1] be
    |   foreach $m$=$a$ with $b$=null be [1]
    |   else be null
    | else be null
    = null

    | foreach $n$=[1] with $a$=null be
    |   foreach $m$=$a$ with $b$=null be [1]
    |   else be null
    | else be null
    = null

    | foreach $n$=null with $a$=null be
    |   foreach $m$=$a$ with $b$=null be [1]
    |   else be null
    | else be null
    = null

Some list-processing-type things that you often see in functional
programming.

Reverse a list.

    | foreach $x$ = [10, 20, 40, 80]
    |     with $a$ = null be
    |         ,$x$,$a$,
    |     else be
    |         null
    = [80,40,20,10]

Find the length and the sum of a list of integers.

    | foreach $x$ = [10, 20, 40]
    |     with $a$ = ,0,0, be
    |         ,+<$a$<0<+1+,+>$a$>0>+$x$+,
    |     else be
    |         null
    = [3|70]

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
    = [[40,20,10],1]

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
    = [[10,20,10,20,10],1]

Macros.
-------

    | {*[Five][5]}{Five}
    = 5

    | {*[(A][1]}+{(A}+4+
    = 5

    | {*[SQR][*{X}*{X}*]}{*[X][5]}{SQR}
    = 25

    | {*[}][This is my comment!]}~${}}$
    = ~$This is my comment!$

    | {*[Dave][3]}{*[Emily][4]}$Number of Macros Defined$
    = 2

    | &~${$&~$*[S][T]}$&
    = ~${*[S][T]}$

    | &~${$&~$S}$&
    = ~${S}$

    | %&~${$&~$*[S][T]}$&%&~${$&~$S}$&%
    = ~$T$

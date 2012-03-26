The Quylthulg Programming Language
==================================

Overview
--------

Here is what is known about the programming language Quylthulg.
Quylthulg:

-   is a programming language;
-   is named Quylthulg;
-   was designed by Chris Pressey;
-   does *not*, quite apart from prevailing trends in programming
    practice, shun the use of `goto`;
-   is, however, somewhat particular about *where* `goto` may be used
    (`goto` may only occur inside a data structure);
-   is purely functional (in the sense that it does not allow
    "side-effectful" updates to values);
-   forbids recursion;
-   provides but a single looping construct: `foreach`, which applies an
    expression successively to each value in a data structure;
-   is Turing-complete; and
-   boasts an argument-less macro expansion facility (in which recursion
    is also forbidden.)

Syntax
------

The syntax for identifiers draws from the best parts of the esteemed
languages BASIC and Perl. Like Perl, all identifiers must be preceded by
a `$` symbol, and like BASIC, all identifiers must be followed by a `$`
symbol. Well, OK, that's for strings anyway, but we don't care about
their types really, so we use `$` for everything. (Also, studies show
that this syntax can help serious TeX addicts from "bugging out".)

A nice practical upshot of this is that identifier names may contain any
characters whatsoever (excepting `$`), including whitespace.

Because of this, the syntax for string literals can be, and is, derived
from the syntax for identifiers. A string literal is given by a `~`
followed by an identifier; the textual content of the name of the
identifier is used as the content of the string literal. A string
literal consisting of a single `$` symbol is given by `~~`.

Many find the syntax for labels to be quite sumilar to that for
identifiers. (Some even find it to be quite similar.) Labels are
preceded and followed by `:` symbols, and may contain any symbol except
for `:`.

Syntax for binary operations follows somewhat in the footsteps of the
identifier syntax. It is a combination of prefix, infix, and postfix
syntax, where the two terms must be preceeded, followed, and seperated
by the same symbol. We call this notation *panfix*. It is perhaps worth
noting that, like postfix, panfix does not require the deployment of
arcane contrivances such as *parentheses* to override a default operator
precedence. At the same time, panfix allows terms to be specified in the
same order and manner as infix, an unquestionably natural and intuitive
notation to those who have become accustomed to it.

So, we give some examples:

    *+1+2+*3*
    &~$The shoes are $&&~~&~$9.99 a pair.$&&

The first example might be stated as (1+2)\*3 in conventional, icky
parenthesis-ful notation, and evaluates to 9. The second evaluates to
the string "The shoes are $9.99 a pair."

There are no unary operators in Quylthulg. (Note that `~` isn't really a
unary operator, actually not an operator at all, because it must be
followed by an identifier, not an expression. Well, maybe it's a special
kind of operator then, an identifier-operator perhaps. But you see what
I'm getting at, don't you? Hopefully not.)

There is a special 6-ary operator, `foreach`. It has its own syntax
which will be covered below.

Data Types
----------

### Strings and Integers

Yes. Also a special type called `abort`, of which there is a single
value `abort`, which you'll learn about later.

### Lists

The sole data structure of note in Quylthulg is the list. Lists are
essentially identical to those found in other functional languages such
as Scheme: they are either the special value `null`, which suggests an
empty list, or they consist of a `cons` cell, which is a pair of two
other values. By convention, the first of this pair is the value of this
list node, and the second is a sublist (a `null` or a `cons`) which
represents the rest of this list.

The value of a list node may be any value: a scalar such as an integer
or a string, another (embedded sub)list, or the special value `abort`.
`cons` cells are constructed by the `,` panfix operator. Some examples
follow:

    ,1,,2,,3,null,,,
    ,1,,2,3,,

The first example constructs a proper list. So-called "improper" lists,
which purely by convention do not end with `null`, can also be
constructed: that's the second example.

When all of the terms involved are literal constants embedded in the
program text, there is a shorthand syntax for these list expressions,
stolen from the Prolog/Erlang school:

    [1, 2, 3]
    [1, 2 | 3]

Note, however, that `[]` is not shorthand for `null`. Note also that
when this syntax is used, all values *must* be literal constants: there
will be no tolerance for variables. There will, however, be tolerance
for `goto`s and labels; see below for more on that.

### Cyclic Lists

Labels and the `goto` construct enable the definition of cyclic data
structures like so:

    :A:[1, 2, 3, goto $A$]
    :B:[1, 2, :C:[3, 4, goto $B$], 5, 6, goto $C$]

Note that this can only be done in literal constant data structure
expressions, not in `,` (`cons`ing) operations or expression involving a
variable. This is to avoid the dynamic construction of labelled terms,
which just a tad mind-bending and which I've decided to save for a
sequel to Quylthulg, whatever and whenever that might be. Note also that
labels have their own syntax during declaration, but (oh so helpfully)
insist on being referred to in `goto`s by the `$` syntax used for
identifiers.

### List Operators

The values contained in a `cons` cell can be extracted by the felicitous
use of the binary operators `<` ('first') and `>` ('rest'). For both of
these operators, the left-hand side is the `cons` cell to operate on,
and the right-hand side is an expression which the operator will
evaluate to in the case that it cannot successfully extract the value
from the `cons` cell (e.g., the left-hand side is not in fact a `cons`
cell but rather something else like a `null` or a number or a string or
`abort`.

There is also an operator `;` which appends one list (the right-hand
side) onto the end of another list (the left-hand side.) This is
probably not strictly necessary, since as we'll see later can probably
build something equivalent using `foreach`es and macros, but what the
hell, we can afford it. Party down.

These list operators honour cyclic lists, so that
`>[:X: 4 | goto :X:]>abort>`, to take just one instance, evaluates to 4.

Control Flow
------------

Quylthulg's sole looping construct, `foreach`, is a recursing abortable
"fold" operation. It is passed a data structure to traverse, an
expression (called the *body*) that it will apply to each value it
encounters in the traversed data structure, and an initial value called
the *accumulator*. Inside the body, two identifiers are bound to two
values: the value in the data structure that the body is currently being
applied to, and the value of the current value. The names of the
idenfiers so bound are specified in the syntax of the `foreach`
operator. The value that the body evaluates to is used as the
accumulator for the next time the body is evaluated, on the next value
in the data structure. The value that `foreach` evaluates to is the
value of the FINAL accumulator (emphasis mine.) The full form of this
operator is as follows:

    foreach $var$ = data-expr with $acc$ = initial-expr be loop-expr else be otherwise-expr

`foreach` traverses the data structure in this manner: from beginning to
end. It is:

-   *recursing*, meaning if the current element of the list is itself a
    (sub)list, `foreach` will begin traversing that (sub)list (with the
    same body and current accumulator, natch) instead of passing the
    (sub)list to the body; and
-   *abortable*, meaning that the callback may evaluate to a special
    value `abort`, which causes traversal of the current (sub)list to
    cease immediately, returning to the traversal of the containing
    list, if any.

If the *data-expr* evaluates to some value besides a `cons` cell (for
example, `null` or an integer or a string), then the *loop-expr* is
ignored and the *otherwise-expr* is evaluated instead.

As an example,

    -foreach $x$ = [2, 3, 4] with $a$ = 1 be *$a$*$x$* else be null-1-

will evaluate to 23. On the other hand,

    foreach $x$ = null with $a$ = 1 be $a$ else be 23

will also evaluate to 23.

Macro System
------------

Quylthulg boasts an argument-less macro expansion system. (Yes, there is
no argument about it: it *boasts* it. It is quite arrogant, you know.)
Where-ever text of the form `{foo}` appears in the source code, the
contents of the macro named `foo` are inserted at that point, replacing
`{foo}`. This process is called the *expansion* of `foo`. But it gets
worse: whereever text of the form `{bar}` appears in the contents of
that macro called `foo`, those too will be replaced by the contents of
the macro called `bar`. And so on. Three things to note:

-   If there is no macro called `foo`, `{foo}` will not be expanded.
-   If `{foo}` appears in the contents of `foo`, it will not be
    expanded.
-   Nor will it be expanded if it appears in the contents of `foo` as
    the result of expanding some other macro in the contents of `foo`.

(I stand corrected. That was more like 2.5 things to note.)

Macros can be defined and redefined with the special macro-like form
`{*[foo][bar]}`. The first text between square brackets is the name of
the macro being defined; the text between the second square brackets is
the contents. Both texts can contain any symbols except unmatched `]`'s.
i.e. you can put square brackets in these texts as long as they nest
properly.

Now you see why we don't need arguments to these macros: you can simply
use macros as arguments. For example,

    {*[SQR][*{X}*{X}*]}{*[X][5]}{SQR}

uses an "argument macro" called `X` which it defines as `5` before
calling the `SQR` macro that uses it.

Note that macros are expanded before any scanning or parsing of the
program text begins. Thus they can be used to define identifiers,
labels, etc.

### Comments

The macro system also provides a way to insert comments into a Quylthulg
program. It should be noted that there are at least three schools of
thought on this subject.

The first school (Chilton County High School in Clanton, Alabama) says
that most comments that programmers write are next to useless anyway
(which is absolutely true) so there's no point in writing them at all.

The second school (Gonzaga College S.J. in Dublin, Ireland — not to be
confused with Gonzaga University in Spokane, Washington) considers
comments to be valuable *as comments*, but not as source code. They
advocate their use in Quylthulg by the definition of macros that are
unlikely to be expanded for obscure syntactical reasons. For example,
`{*[}][This is my comment!]}`. Note that that macro *can* be expanded in
Quylthulg using `{}}`; it's just that the Gonzaga school hopes that you
won't do that, and hopes you get a syntax error if you try.

The third school (a school of fish) believes that comments are valuable,
not just as comments, but also as integral (or at least distracting)
part of the computation, and champions their use in Quylthulg as string
literals involved in expressions that are ultimately discarded. For
example, `<"Addition is fun!"<+1+2+<`.

### Integration with the Rest of the Language

To dispel the vicious rumours that the macro system used in Quylthulg
and the Quylthulg language are really independent and separate entities
which just *happen* to be sandwiched together there, we are quick to
point out that they are bound by two very important means:

-   At the beginning of the program, at a global scope, the identifier
    `$Number of Macros Defined$` is bound to an integer constant
    containing the number of unique macros that were defined during
    macro expansion before the program was parsed.
-   The panfix operator `%` applies macros to a Quylthulg string at
    runtime. The expression on the left-hand side should evaluate to a
    string which contains macro definitions. The expression on the
    right-hand side is the string to expand using these macro
    definitions.

Turing-Completeness
-------------------

Now, I claim that Quylthulg is Turing-complete — that is, that it can
compute anything that a Turing machine (or any other Turing-complete
system) can. I would provide a proof, but since the point of a proof is
to dispel doubt, and since you have not expressed any doubt so far (at
least none that I have been able to observe from my vantage point), and
since (statistically speaking anyway) you believe that fluoride in
drinking water promotes dental health, that the sun is a giant nuclear
furnace, that Wall Street is substantially different from Las Vegas,
that a low-fat diet is an effective way to lose weight, that black holes
exist, and that point of the War on Drugs is to stop people from harming
themselves — well, in light of all that, a proof hardly seems
called-for. Instead, I shall perform a series of short vignettes, each
intended to invoke the spirit of a different forest animal or
supermarket checkout animal. Then I shall spray you with a dose of a new
household aerosol which I have invented and which I am marketing under
the name "Doubt-B-Gone".

-   We can use `foreach` as an if-then-else construct by using lists to
    represent booleans.

    Using `null` to represent false, and `cons` anything to represent
    true, we use the `else` part of `foreach` to accomplish a boolean
    if-then-else. We can employ `;` to get boolean OR and nested
    `foreach`es to get boolean AND. (Detailed examples of these can be
    found in the unit tests of the Quylthulg reference interpreter,
    which is called "Qlzqqlzuup, Lord of Flesh".)

-   We can construct an infinite loop by running `foreach` on a cyclic
    data structure.

    For example,

        foreach $x$ = :L:[1, 2, 3, goto L] with $a$ = 0 be $x$ else be null

    never finishes evaluating, and in the body, `$x$` takes on the
    values 1, 2, 3, 1, 2, 3, ... ad infinitum.

-   We can treat the accumulator of a `foreach` like an unbounded tape,
    just like on a Turing machine.

    We can pass in a `cons` cell where the first value is a list
    representing everything to the left of the head, and the second
    value is a list representing everything to the right of the head.
    Moving the head left or right can be accomplished by taking the
    first (`<`) off the appropriate list and cons (`,`) it onto the
    other list. There are also other ways to do it, of course. The point
    is that there is no bound specified on the length of a list in
    Quylthulg.

-   We can, in fact, make `foreach` act like a `while` construct.

    We just combine the looping forever with an if-then-else which
    evaluates to `abort` when the condition comes true.

-   We can give `foreach` a cyclic tree-like data structure which
    describes the finite control of a Turing machine.

    Although we don't have to — we could just use nested `foreach`es to
    make a lot of tests against constant values.

-   We can even make `foreach` work like `let` if we need to.

    Just bind the accumulator to `$Name$`, refer to `$Name$` in the
    body, and ignore the contents of the one-element list. Or use it to
    bind two variables in one `foreach`.

PHHSHHHHHHHHHHHHHHTt.

Discussion
----------

Now I'm hardly the first person to suggest using cyclic lists as an
equivalent alternative to a general looping construct such as `while`.
It has long been a [stylish LISP programming
technique](http://www.ccs.neu.edu/home/shivers/newstyle.html). However,
to comply with the Nietzschean-Calvinist mandate of our society (that
is, to *sustain* the *progress* that will *thrust* us toward the
"Perfect Meat at the End of Time" of which Hegel spoke,) we must
*demonstrate* that we have **innovated**:

-   Quylthulg provides *only* this method of looping; without it, it
    would not be Turing-complete, and
-   Unlike the extant stylish programming techniques, which require
    side-effecting operations such as `rplacd` to pull off, Quylthulg is
    a pure functional programming language *without* updatable storage.

Huzzah.

It is somewhat sad to consider just how long Quylthulg took to design
and how much of that labour took place aboard airplanes. It is even
sadder to consider some of the delusions I was occupied with while
designing it. Some of the biggest were the idea that `foreach` somehow
had to be recursable for this to work — it doesn't, but I left it in.
For similar reasons I left in `;`, the append operator. And I've already
mentioned the headaches with allowing labels and `goto`s in expressions
rather than only in literals.

Long live the new flesh, eh?  
Chris Pressey  
Seattle, Washington  
Dec 6, 2008

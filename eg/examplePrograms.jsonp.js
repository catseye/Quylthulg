examplePrograms = [
    {
        "contents": "foreach $x$ = :L:[1, 2, 3, goto $L$] with $a$ = 0 be $x$ else be null\n", 
        "filename": "infinite-loop.quylthulg"
    }, 
    {
        "contents": "foreach $x$ = [10, 20, 40]\n    with $a$ = ,0,0, be\n        ,+<$a$<0<+1+,+>$a$>0>+$x$+,\n    else be\n        null\n", 
        "filename": "length-and-sum.quylthulg"
    }, 
    {
        "contents": "foreach $x$ = [10, 20, 40, 80]\n    with $a$ = null be\n        ,$x$,$a$,\n    else be\n        null\n", 
        "filename": "reverse.quylthulg"
    }, 
    {
        "contents": "{*[SQR][*{X}*{X}*]}{*[X][5]}{SQR}\n", 
        "filename": "square.quylthulg"
    }, 
    {
        "contents": "foreach $x$ = [10, 20, 40, 80, 60, 10, 30]\n    with $a$ = ,null,[1,1,1,1], be\n        foreach $n$=>>$a$>null>>null>\n            with $r$=99999 be\n                ,,$x$,<$a$<null<,,>>$a$>null>>null>,\n            else be\n                abort\n    else be\n        null\n", 
        "filename": "take-3-reverse.quylthulg"
    }, 
    {
        "contents": "foreach $x$ = :L:[10, 20, goto $L$]\n    with $a$ = ,null,[1,1,1,1,1,1], be\n        foreach $n$=>>$a$>null>>null>\n            with $r$=99999 be\n                ,,$x$,<$a$<null<,,>>$a$>null>>null>,\n            else be\n                abort\n    else be\n        null\n", 
        "filename": "take-5-from-cyclic-list.quylthulg"
    }
];

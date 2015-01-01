--
-- Copyright (c)2008-2015 Chris Pressey, Cat's Eye Technologies.
-- All rights reserved.
--
-- Redistribution and use in source and binary forms, with or without
-- modification, are permitted provided that the following conditions
-- are met:
--
--   1. Redistributions of source code must retain the above copyright
--      notices, this list of conditions and the following disclaimer.
--   2. Redistributions in binary form must reproduce the above copyright
--      notices, this list of conditions, and the following disclaimer in
--      the documentation and/or other materials provided with the
--      distribution.
--   3. Neither the names of the copyright holders nor the names of their
--      contributors may be used to endorse or promote products derived
--      from this software without specific prior written permission. 
--
-- THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
-- ``AS IS'' AND ANY EXPRESS OR IMPLIED WARRANTIES INCLUDING, BUT NOT
-- LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
-- FOR A PARTICULAR PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL THE
-- COPYRIGHT HOLDERS OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,
-- INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
-- BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
-- LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
-- CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
-- LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN
-- ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
-- POSSIBILITY OF SUCH DAMAGE.
--

--
-- Qlzqqlzuup.hs revision 2015.0101
--
-- 'Qlzqqlzuup, the Lord of Flesh': Reference interpreter for
-- The Quylthulg Programming Language
-- v1.0
--

module Qlzqqlzuup where

import Data.Char

-- ============ --
-- Environments --
-- ============ --

--
-- Environments associate names with values.  Environments are used in three
-- places in this interpreter: to associate variable names with the values
-- bound to them, to associate macro names with the replacement text of each
-- macro, and to associate label names with the term being labelled.
--

findVal ((key,val):rest) x
    | key == x = val
    | otherwise = findVal rest x

extendEnv env key val = ((key, val):env)

newEnv = []

purgeEnv [] x = []
purgeEnv ((key, val):rest) x
    | key == x = purgeEnv rest x
    | otherwise = ((key, val):purgeEnv rest x)

-- ===== --
-- Terms --
-- ===== --

data Term = Int Integer
          | Str String
          | Cons Term Term
          | Null
          | Label String Term
          | Goto String
          | Abort
    deriving (Show, Ord, Eq)

follow lenv (Label _ x) = follow lenv x
follow lenv (Goto label) = follow lenv (findVal lenv label)
follow lenv y = y

--
-- Terms support a number of operations which require the "meaning" of the
-- term, which may not be available in the term itself, since the term
-- might be a goto to a label which is labelling another quite disjoint
-- term.  For these operations, an environment mapping labels to terms
-- is also passed, so that gotos can be followed.
--

type Op = [(String, Term)] -> Term -> Term -> Term

reduce lenv termA termB fn extract package =
    let
       valA = extract (follow lenv termA)
       valB = extract (follow lenv termB)
    in
       package (fn valA valB)

strCat lenv a b = reduce lenv a b (++) (\(Str k) -> k) (\k -> Str k)

strExpand lenv a b =
    reduce lenv a b (spander) (\(Str k) -> k) (\k -> Str k)
    where
        spander x y =
            let
                (expansions, expanded) = expand [("*","")] x
                (_, expanded') = expand expansions y
            in
                expanded'

intAdd lenv a b = reduce lenv a b (+) (\(Int k) -> k) (\k -> Int k)
intMul lenv a b = reduce lenv a b (*) (\(Int k) -> k) (\k -> Int k)
intSub lenv a b = reduce lenv a b (-) (\(Int k) -> k) (\k -> Int k)

listCons lenv a b =
    let
        valA = follow lenv a
        valB = follow lenv b
    in
        Cons valA valB

listFirst lenv term omgNo =
    follow lenv (first (follow lenv term))
    where
        first (Cons a b) = a
        first _ = omgNo

listRest lenv term omgNo =
    follow lenv (rest (follow lenv term))
    where
        rest (Cons a b) = b
        rest _ = omgNo

listAppend lenv a b =
    let
        valA = follow lenv a
        valB = follow lenv b
    in
        if valA == Null then
            valB
        else
            Cons (listFirst lenv valA Null) (listAppend lenv (listRest lenv valA Null) valB)

-- =========== --
-- Expressions --
-- =========== --

data Expr = Term Term
          | Ident String
          | ForEach String Expr String Expr Expr Expr
          | BinOp Op Expr Expr

instance Show Expr where
    show (Term t) =
        show t
    show (Ident s) = 
        "$" ++ s ++ "$"
    show (ForEach x lis a acc body els) =
        "foreach " ++ (show x) ++ "=" ++ (show lis) ++ " with " ++ (show a) ++ "=" ++ (show acc) ++
        " be " ++ (show body) ++ " else be " ++ (show els)
    show (BinOp op lhs rhs) =
        "(" ++ (show lhs) ++ "," ++ (show rhs) ++ ")"

collectExprLabels (Term p) = collectTermLabels p
collectExprLabels (Ident _) = []
collectExprLabels (ForEach _ e1 _ e2 e3 e4) =
    collectExprLabels e1 ++ collectExprLabels e2 ++ collectExprLabels e3 ++ collectExprLabels e4
collectExprLabels (BinOp _ a b) = collectExprLabels a ++ collectExprLabels b

collectTermLabels (Int _) = []
collectTermLabels (Str _) = []
collectTermLabels (Cons a b) = collectTermLabels a ++ collectTermLabels b
collectTermLabels (Null) = []
collectTermLabels (Label label term) = ((label, term): collectTermLabels term)
collectTermLabels (Goto _) = []
collectTermLabels (Abort) = []

-- =========== --
-- Interpreter --
-- =========== --

interpret :: [(String, Term)] -> [(String, Term)] -> Expr -> Term

interpret env lenv (Term x) =
    x
interpret env lenv (Ident x) =
    findVal env x

interpret env lenv (BinOp op a b) =
    let
        ra = interpret env lenv a
        rb = interpret env lenv b
        result = op lenv ra rb
    in
        result

--
-- The coup de grace, or perhaps coup d'etat: interpret foreach.
--

interpret env lenv (ForEach loopvar listExpr accvar accExpr applyExpr elseExpr) =
    let
        list = interpret env lenv listExpr
        acc  = interpret env lenv accExpr
    in
        if list == Null then
            interpret env lenv elseExpr
        else
            qForEach list acc
    where
        qForEach Null acc = acc
        qForEach (Cons first@(Cons _ _) rest) acc =
            let
                first' = follow lenv first
                deepResult = qForEach first' acc
                newAcc = follow lenv deepResult
                nextResult = qForEach rest newAcc
            in
                follow lenv nextResult
        qForEach (Cons first rest) acc =
            let
                first' = follow lenv first
                env' = extendEnv env accvar acc
                env'' = extendEnv env' loopvar first'
                result = interpret env'' lenv applyExpr
                newAcc = follow lenv result
                nextResult = qForEach rest newAcc
            in
                if newAcc == Abort then
                    acc
                else
                    follow lenv nextResult

-- =================== --
-- Monadic Interpreter --
-- =================== --

mInterpret :: [(String, Term)] -> [(String, Term)] -> Expr -> IO Term

mInterpret env lenv (Term x) =
    return x
mInterpret env lenv (Ident x) =
    return (findVal env x)

mInterpret env lenv (BinOp op a b) = do
    ra <- mInterpret env lenv a
    rb <- mInterpret env lenv b
    return (op lenv ra rb)

--
-- The coup de grace, or perhaps coup d'etat: interpret foreach.
--

mInterpret env lenv (ForEach loopvar listExpr accvar accExpr applyExpr elseExpr) = do
    list <- mInterpret env lenv listExpr
    acc <- mInterpret env lenv accExpr
    if
        list == Null
      then
        mInterpret env lenv elseExpr
      else
        mqForEach list acc
    where
        mqForEach Null acc =
            return acc
        mqForEach (Cons first@(Cons _ _) rest) acc = do
            deepResult <- mqForEach (follow lenv first) acc
            nextResult <- mqForEach rest (follow lenv deepResult)
            return (follow lenv nextResult)
        mqForEach (Cons first rest) acc = do
            result <- mInterpret (
                        extendEnv (extendEnv env accvar acc) loopvar (follow lenv first)
                      ) lenv applyExpr
            newAcc <- do return (follow lenv result)
            nextResult <- mqForEach rest newAcc
            return (if newAcc == Abort then
                        acc
                    else
                        follow lenv nextResult)

-- =========== --
-- ParseEngine --
-- =========== --

data Expected = Token String
              | Expr

parseEngine [] string = ([], string)

parseEngine (Token token:es) string =
    parseEngine es (expect token string)

parseEngine (Expr:es) string =
    let
        (expr, rest) = parse string
        (more, final) = parseEngine es rest
    in
        ((expr:more), final)

--
-- Given a mapping (as a list of pairs) between tokens
-- and functions to parse what comes after those tokens,
-- check the beginning of the given string for each of
-- those tokens and, upon a match, parse appropriately.
--

parseToken [] string omgNo = (omgNo string)
parseToken ((token, func):rest) string omgNo =
    if take (length token) string == token then
        func (drop (length token) string)
    else
        parseToken rest string omgNo

expect token string@(char:chars)
    | isSpace char =
        expect token chars
    | take (length token) string == token =
        drop (length token) string

stripspace [] = []
stripspace string@(char:chars)
    | isSpace char =
        stripspace chars
    | otherwise = string

-- =========== --
-- Term Parser --
-- =========== --

--
-- This just handles constant literal terms.  It is called
-- by the general parser when it doesn't know what else it
-- should do.
--

parseTerm string@(char:chars)
    | isSpace char =
        parseTerm chars
    | isDigit char =
        parseIntLit string 0
    | otherwise =
        parseToken termTokenList string omgNo
    where
        omgNo string = ((Str "BADTERM"), string)

termTokenList = [
    ("~~",      \string -> ((Str "$"), string)),
    ("~",       \string ->
                    let
                        ((Ident text), rest) = parse string
                    in
                        ((Str text), rest)),
    ("[",       parseList),
    (":",       parseLabel),
    ("null",    \string -> (Null, string)),
    ("abort",   \string -> (Abort, string)),
    ("goto",    \string ->
                    let
                        ((Ident label), rest) = parse string
                    in
                        ((Goto label), rest))
    ]

--
-- Parse Prolog/Erlang-derived constant list syntax.
--

parseList string =
    let
        (terma, rest) = parseTerm string
        rest' = stripspace rest
        (termb, rest'') = parseList' rest'
    in
        (Cons terma termb, rest'')

parseList' (',':rest) = parseList rest
parseList' (']':rest) = (Null, rest)
parseList' ('|':rest) =
    let
        (term, rest') = parseTerm rest
        rest'' = expect "]" rest'
    in
        (term, rest'')

--
-- Parse labels and identifiers.
--

parseLabel string =
    let
        (label, rest) = parseLabel' string
        (term, rest2) = parseTerm rest
    in
        (Label label term, rest2)

parseLabel' (':':chars) =
    ("", chars)
parseLabel' string@(char:chars) =
    let
        (movie, rest) = parseLabel' chars
    in
        ((char:movie), rest)

parseIdent ('$':chars) =
    (Ident "", chars)
parseIdent string@(char:chars) =
    let
        ((Ident movie), rest) = parseIdent chars
    in
        (Ident (char:movie), rest)

parseFullIdent string = parseIdent (expect "$" string)

--
-- Parse nested strings.
--

parseNestedString string =
    parseNestedString' 0 (expect "[" string)

parseNestedString' 0 (']':chars) =
    ("", chars)
parseNestedString' level string@(char:chars) =
    let
        newLevel = level + adjustLevel char
        (movie, rest) = parseNestedString' newLevel chars
    in
        ((char:movie), rest)
    where
        adjustLevel '[' = 1
        adjustLevel ']' = -1
        adjustLevel _ = 0

--
-- Parse numbers.
--

digitVal '0' = 0
digitVal '1' = 1
digitVal '2' = 2
digitVal '3' = 3
digitVal '4' = 4
digitVal '5' = 5
digitVal '6' = 6
digitVal '7' = 7
digitVal '8' = 8
digitVal '9' = 9

parseIntLit "" num = ((Int num), "")
parseIntLit string@(char:chars) num
    | isDigit char =
        parseIntLit chars (num * 10 + digitVal char)
    | otherwise =
        ((Int num), string)

-- ====== --
-- Parser --
-- ====== --

parse string@(char:chars)
    | isSpace char =
        parse chars
    | otherwise =
        parseToken tokenList string omgNo
    where
        omgNo string =
            let
                (term, rest) = parseTerm string
            in
                ((Term term), rest)

tokenList = [
    ("$",       parseIdent),
    ("<",       parsePanfix "<" listFirst),
    (">",       parsePanfix ">" listRest),
    (",",       parsePanfix "," listCons),
    (";",       parsePanfix ";" listAppend),
    ("&",       parsePanfix "&" strCat),
    ("%",       parsePanfix "%" strExpand),
    ("+",       parsePanfix "+" intAdd),
    ("-",       parsePanfix "-" intSub),
    ("*",       parsePanfix "*" intMul),
    ("foreach", parseForEach)
    ]

parsePanfix delim op string =
    let
        (expr1, rest1) = parse string
        rest2 = expect delim rest1
        (expr2, rest3) = parse rest2
        rest4 = expect delim rest3
    in
        ((BinOp op expr1 expr2), rest4)

parseForEach string =
    let
        rules = [Expr, Token "=", Expr, Token "with", Expr, Token "=", Expr, Token "be", Expr, Token "else", Token "be", Expr]
        ([(Ident loopvar), list, (Ident accvar), acc, expr, elsepart], rest) = parseEngine rules string
    in
        (ForEach loopvar list accvar acc expr elsepart, rest)

-- ============== --
-- Macro Expander --
-- ============== --

--
-- A macro environment maps macro names to macro definitions.  A macro name
-- is a string.  It would have been really nice to have a macro definition
-- be a function which takes a string (the input stream) and which returns
-- a string (the transformed input stream) and a new macro environment (for
-- macros which can define other macros.)  But that means that macro env-
-- ironments would be of infinite type, and sadly, Haskell doesn't like that
-- very much.  Instead, a macro definition is simply a string as well, and
-- some macro names (namely "*") are treated specially.
--

expand env "" =
    (env, "")
expand env ('{':chars) =
    expandMacro env env chars
expand env (char:chars) =
    let
        (env', rest) = (expand env chars)
    in
        (env', (char:rest))

expandMacro env [] string =
    let
        (env', more) = expand env string
    in
        (env', "{" ++ more)
expandMacro env ((name, body):defns) string =
    if take (length name) string == name then
        let
            rest = (drop (length name) string)
            (env', subst, rest') = handleMacro env name body rest
            (env'', rest'') = expand env' rest'
        in
            (env'', subst ++ rest'')
    else
        expandMacro env defns string

handleMacro env "*" _ rest =
    let
        (name, rest2) = parseNestedString rest
        (body, rest3) = parseNestedString rest2
        env' = ((name, body):env)
    in
        (env', "", (expect "}" rest3))

handleMacro env name body rest =
    let
        env' = purgeEnv env name
        (env'', expanded) = expand env' body
    in
        if expanded == body then
            (env, expanded, (expect "}" rest))
        else
            handleMacro env'' name expanded rest

-- ======== --
-- Toplevel --
-- ======== --

integerLength [] = (0 :: Integer)
integerLength (x:y) = (1 :: Integer) + integerLength y

initialEnv expansions =
    let
        numberOfMacrosDefined = (integerLength expansions) - 1
    in
        extendEnv newEnv "Number of Macros Defined" (Int numberOfMacrosDefined)

parsed program =
    let
        (_, expanded) = expand [("*","")] program
        (expr, _) = parse expanded
    in
        expr

run program =
    let
        (expansions, expanded) = expand [("*","")] program
        (expr, _) = parse expanded
        lenv = collectExprLabels expr
        env = initialEnv expansions
        result = interpret env lenv expr
    in
        result

showRun = show . run

mrun :: String -> IO Term

mrun program = do
    (expansions, expanded) <- return (expand [("*","")] program)
    expr <- return (fst (parse expanded))
    lenv <- return (collectExprLabels expr)
    env <- return (initialEnv expansions)
    result <- mInterpret env lenv expr
    print result
    return result

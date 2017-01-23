{-# OPTIONS_GHC -fno-warn-incomplete-patterns #-}
module PrintMinSQL where

-- pretty-printer generated by the BNF converter

import AbsMinSQL
import Data.Char


-- the top-level printing method
printTree :: Print a => a -> String
printTree = render . prt 0

type Doc = [ShowS] -> [ShowS]

doc :: ShowS -> Doc
doc = (:)

render :: Doc -> String
render d = rend 0 (map ($ "") $ d []) "" where
  rend i ss = case ss of
    "["      :ts -> showChar '[' . rend i ts
    "("      :ts -> showChar '(' . rend i ts
    "{"      :ts -> showChar '{' . new (i+1) . rend (i+1) ts
    "}" : ";":ts -> new (i-1) . space "}" . showChar ';' . new (i-1) . rend (i-1) ts
    "}"      :ts -> new (i-1) . showChar '}' . new (i-1) . rend (i-1) ts
    ";"      :ts -> showChar ';' . new i . rend i ts
    t  : "," :ts -> showString t . space "," . rend i ts
    t  : ")" :ts -> showString t . showChar ')' . rend i ts
    t  : "]" :ts -> showString t . showChar ']' . rend i ts
    t        :ts -> space t . rend i ts
    _            -> id
  new i   = showChar '\n' . replicateS (2*i) (showChar ' ') . dropWhile isSpace
  space t = showString t . (\s -> if null s then "" else (' ':s))

parenth :: Doc -> Doc
parenth ss = doc (showChar '(') . ss . doc (showChar ')')

concatS :: [ShowS] -> ShowS
concatS = foldr (.) id

concatD :: [Doc] -> Doc
concatD = foldr (.) id

replicateS :: Int -> ShowS -> ShowS
replicateS n f = concatS (replicate n f)

-- the printer class does the job
class Print a where
  prt :: Int -> a -> Doc
  prtList :: [a] -> Doc
  prtList = concatD . map (prt 0)

instance Print a => Print [a] where
  prt _ = prtList

instance Print Char where
  prt _ s = doc (showChar '\'' . mkEsc '\'' s . showChar '\'')
  prtList s = doc (showChar '"' . concatS (map (mkEsc '"') s) . showChar '"')

mkEsc :: Char -> Char -> ShowS
mkEsc q s = case s of
  _ | s == q -> showChar '\\' . showChar s
  '\\'-> showString "\\\\"
  '\n' -> showString "\\n"
  '\t' -> showString "\\t"
  _ -> showChar s

prPrec :: Int -> Int -> Doc -> Doc
prPrec i j = if j<i then parenth else id


instance Print Integer where
  prt _ x = doc (shows x)


instance Print Double where
  prt _ x = doc (shows x)


instance Print Ident where
  prt _ (Ident i) = doc (showString ( i))
  prtList es = case es of
   [x] -> (concatD [prt 0 x])
   x:xs -> (concatD [prt 0 x , doc (showString ",") , prt 0 xs])


instance Print Str where
  prt _ (Str i) = doc (showString ( i))



instance Print Script where
  prt i e = case e of
   SStm statements -> prPrec i 0 (concatD [prt 0 statements])


instance Print Statement where
  prt i e = case e of
   SCreateDatabase id -> prPrec i 0 (concatD [doc (showString "CREATE") , doc (showString "DATABASE") , prt 0 id])
   SCreateTable id typings -> prPrec i 0 (concatD [doc (showString "CREATE") , doc (showString "TABLE") , prt 0 id , doc (showString "(") , prt 0 typings , doc (showString ")")])
   SDropTable id typings -> prPrec i 0 (concatD [doc (showString "DROP") , doc (showString "TABLE") , prt 0 id , doc (showString "(") , prt 0 typings , doc (showString ")")])
   SInsert id tableplaces insertvalues -> prPrec i 0 (concatD [doc (showString "INSERT") , doc (showString "INTO") , prt 0 id , prt 0 tableplaces , prt 0 insertvalues])
   SDelete id where' -> prPrec i 0 (concatD [doc (showString "DELETE") , doc (showString "FROM") , prt 0 id , prt 0 where'])
   SUpdate id settings where' -> prPrec i 0 (concatD [doc (showString "UPDATE") , prt 0 id , doc (showString "SET") , prt 0 settings , prt 0 where'])
   SCreateView id query -> prPrec i 0 (concatD [doc (showString "CREATE") , doc (showString "VIEW") , prt 0 id , doc (showString "AS") , prt 0 query])
   SAlterTable id alterations -> prPrec i 0 (concatD [doc (showString "ALTER") , doc (showString "TABLE") , prt 0 id , prt 0 alterations])
   SCreateAssertion id condition -> prPrec i 0 (concatD [doc (showString "CREATE") , doc (showString "ASSERTION") , prt 0 id , doc (showString "CHECK") , doc (showString "(") , prt 0 condition , doc (showString ")")])
   SCreateTrigger id0 triggertime triggeractions id triggereach triggerbody -> prPrec i 0 (concatD [doc (showString "CREATE") , doc (showString "TRIGGER") , prt 0 id0 , prt 0 triggertime , prt 0 triggeractions , doc (showString "ON") , prt 0 id , doc (showString "FOR") , doc (showString "EACH") , prt 0 triggereach , prt 0 triggerbody])
   SQuery query -> prPrec i 0 (concatD [prt 0 query])

  prtList es = case es of
   [] -> (concatD [])
   x:xs -> (concatD [prt 0 x , doc (showString ";") , prt 0 xs])

instance Print Query where
  prt i e = case e of
   QSelect distinct columns tables where' group having order -> prPrec i 2 (concatD [doc (showString "SELECT") , prt 0 distinct , prt 0 columns , doc (showString "FROM") , prt 0 tables , prt 0 where' , prt 0 group , prt 0 having , prt 0 order])
   QSetOperation query0 setoperation all query -> prPrec i 1 (concatD [prt 1 query0 , prt 0 setoperation , prt 0 all , prt 2 query])
   QWith definitions query -> prPrec i 0 (concatD [doc (showString "WITH") , prt 0 definitions , prt 0 query])


instance Print Table where
  prt i e = case e of
   TName id -> prPrec i 1 (concatD [prt 0 id])
   TTableAs table id -> prPrec i 1 (concatD [prt 1 table , doc (showString "AS") , prt 0 id])
   TQuery query id -> prPrec i 1 (concatD [doc (showString "(") , prt 0 query , doc (showString ")") , doc (showString "AS") , prt 0 id])
   TJoin table0 jointype table joinon -> prPrec i 0 (concatD [prt 0 table0 , prt 0 jointype , doc (showString "JOIN") , prt 1 table , prt 0 joinon])
   TNaturalJoin table0 jointype table -> prPrec i 0 (concatD [prt 0 table0 , doc (showString "NATURAL") , prt 0 jointype , doc (showString "JOIN") , prt 1 table])

  prtList es = case es of
   [x] -> (concatD [prt 0 x])
   x:xs -> (concatD [prt 0 x , doc (showString ",") , prt 0 xs])

instance Print Columns where
  prt i e = case e of
   CCAll  -> prPrec i 0 (concatD [doc (showString "*")])
   CCExps columns -> prPrec i 0 (concatD [prt 0 columns])


instance Print Column where
  prt i e = case e of
   CExp exp -> prPrec i 0 (concatD [prt 0 exp])
   CExpAs exp id -> prPrec i 0 (concatD [prt 0 exp , doc (showString "AS") , prt 0 id])

  prtList es = case es of
   [x] -> (concatD [prt 0 x])
   x:xs -> (concatD [prt 0 x , doc (showString ",") , prt 0 xs])

instance Print Where where
  prt i e = case e of
   WNone  -> prPrec i 0 (concatD [])
   WCondition condition -> prPrec i 0 (concatD [doc (showString "WHERE") , prt 0 condition])


instance Print Condition where
  prt i e = case e of
   COper exp oper compared -> prPrec i 3 (concatD [prt 0 exp , prt 0 oper , prt 0 compared])
   CNot condition -> prPrec i 2 (concatD [doc (showString "NOT") , prt 3 condition])
   CExists not query -> prPrec i 2 (concatD [prt 0 not , doc (showString "EXISTS") , doc (showString "(") , prt 0 query , doc (showString ")")])
   CIsNull exp not -> prPrec i 2 (concatD [prt 0 exp , doc (showString "IS") , prt 0 not , doc (showString "NULL")])
   CBetween exp0 not exp1 exp -> prPrec i 2 (concatD [prt 0 exp0 , prt 0 not , doc (showString "BETWEEN") , prt 0 exp1 , doc (showString "AND") , prt 0 exp])
   CIn exp not values -> prPrec i 2 (concatD [prt 0 exp , prt 0 not , doc (showString "IN") , prt 0 values])
   CAnd condition0 condition -> prPrec i 1 (concatD [prt 1 condition0 , doc (showString "AND") , prt 2 condition])
   COr condition0 condition -> prPrec i 0 (concatD [prt 0 condition0 , doc (showString "OR") , prt 1 condition])


instance Print Not where
  prt i e = case e of
   NNot  -> prPrec i 0 (concatD [doc (showString "NOT")])
   NNone  -> prPrec i 0 (concatD [])


instance Print Compared where
  prt i e = case e of
   ComExp exp -> prPrec i 0 (concatD [prt 0 exp])
   ComAny values -> prPrec i 0 (concatD [doc (showString "ANY") , prt 0 values])
   ComAll values -> prPrec i 0 (concatD [doc (showString "ALL") , prt 0 values])


instance Print Exp where
  prt i e = case e of
   EName id -> prPrec i 4 (concatD [prt 0 id])
   EQual id0 id -> prPrec i 4 (concatD [prt 0 id0 , doc (showString ".") , prt 0 id])
   EInt n -> prPrec i 4 (concatD [prt 0 n])
   EFloat d -> prPrec i 4 (concatD [prt 0 d])
   EStr str -> prPrec i 4 (concatD [prt 0 str])
   EString str -> prPrec i 4 (concatD [prt 0 str])
   ENull  -> prPrec i 4 (concatD [doc (showString "NULL")])
   EDefault  -> prPrec i 4 (concatD [doc (showString "DEFAULT")])
   EQuery query -> prPrec i 4 (concatD [doc (showString "(") , prt 2 query , doc (showString ")")])
   EAggr aggroper distinct exp -> prPrec i 4 (concatD [prt 0 aggroper , doc (showString "(") , prt 0 distinct , prt 0 exp , doc (showString ")")])
   EAggrAll aggroper distinct -> prPrec i 4 (concatD [prt 0 aggroper , doc (showString "(") , prt 0 distinct , doc (showString "*") , doc (showString ")")])
   EMul exp0 exp -> prPrec i 2 (concatD [prt 2 exp0 , doc (showString "*") , prt 3 exp])
   EDiv exp0 exp -> prPrec i 2 (concatD [prt 2 exp0 , doc (showString "/") , prt 3 exp])
   ERem exp0 exp -> prPrec i 2 (concatD [prt 2 exp0 , doc (showString "%") , prt 3 exp])
   EAdd exp0 exp -> prPrec i 1 (concatD [prt 1 exp0 , doc (showString "+") , prt 2 exp])
   ESub exp0 exp -> prPrec i 1 (concatD [prt 1 exp0 , doc (showString "-") , prt 2 exp])

  prtList es = case es of
   [x] -> (concatD [prt 0 x])
   x:xs -> (concatD [prt 0 x , doc (showString ",") , prt 0 xs])

instance Print SetOperation where
  prt i e = case e of
   SOUnion  -> prPrec i 0 (concatD [doc (showString "UNION")])
   SOIntersect  -> prPrec i 0 (concatD [doc (showString "INTERSECT")])
   SOExcept  -> prPrec i 0 (concatD [doc (showString "EXCEPT")])


instance Print All where
  prt i e = case e of
   ANone  -> prPrec i 0 (concatD [])
   AAll  -> prPrec i 0 (concatD [doc (showString "ALL")])


instance Print JoinOn where
  prt i e = case e of
   JOCondition condition -> prPrec i 0 (concatD [doc (showString "ON") , prt 0 condition])
   JOUsing ids -> prPrec i 0 (concatD [doc (showString "USING") , doc (showString "(") , prt 0 ids , doc (showString ")")])


instance Print JoinType where
  prt i e = case e of
   JTLeft outer -> prPrec i 0 (concatD [doc (showString "LEFT") , prt 0 outer])
   JTRight outer -> prPrec i 0 (concatD [doc (showString "RIGHT") , prt 0 outer])
   JTFull outer -> prPrec i 0 (concatD [doc (showString "FULL") , prt 0 outer])
   JTInner  -> prPrec i 0 (concatD [doc (showString "INNER")])


instance Print Outer where
  prt i e = case e of
   OutOuter  -> prPrec i 0 (concatD [doc (showString "OUTER")])
   OutNone  -> prPrec i 0 (concatD [])


instance Print Distinct where
  prt i e = case e of
   DNone  -> prPrec i 0 (concatD [])
   DDistinct  -> prPrec i 0 (concatD [doc (showString "DISTINCT")])


instance Print Group where
  prt i e = case e of
   GNone  -> prPrec i 0 (concatD [])
   GGroupBy exps -> prPrec i 0 (concatD [doc (showString "GROUP") , doc (showString "BY") , prt 0 exps])


instance Print Having where
  prt i e = case e of
   HNone  -> prPrec i 0 (concatD [])
   HCondition condition -> prPrec i 0 (concatD [doc (showString "HAVING") , prt 0 condition])


instance Print Order where
  prt i e = case e of
   ONone  -> prPrec i 0 (concatD [])
   OOrderBy attributeorders -> prPrec i 0 (concatD [doc (showString "ORDER") , doc (showString "BY") , prt 0 attributeorders])


instance Print AttributeOrder where
  prt i e = case e of
   AOAsc exp -> prPrec i 0 (concatD [prt 4 exp])
   AODesc exp -> prPrec i 0 (concatD [prt 4 exp , doc (showString "DESC")])

  prtList es = case es of
   [x] -> (concatD [prt 0 x])
   x:xs -> (concatD [prt 0 x , doc (showString ",") , prt 0 xs])

instance Print Setting where
  prt i e = case e of
   SVal id exp -> prPrec i 0 (concatD [prt 0 id , doc (showString "=") , prt 0 exp])

  prtList es = case es of
   [x] -> (concatD [prt 0 x])
   x:xs -> (concatD [prt 0 x , doc (showString ",") , prt 0 xs])

instance Print AggrOper where
  prt i e = case e of
   AOMax  -> prPrec i 0 (concatD [doc (showString "MAX")])
   AOMin  -> prPrec i 0 (concatD [doc (showString "MIN")])
   AOAvg  -> prPrec i 0 (concatD [doc (showString "AVG")])
   AOCount  -> prPrec i 0 (concatD [doc (showString "COUNT")])
   AOSum  -> prPrec i 0 (concatD [doc (showString "SUM")])


instance Print Oper where
  prt i e = case e of
   OEq  -> prPrec i 0 (concatD [doc (showString "=")])
   ONeq  -> prPrec i 0 (concatD [doc (showString "<>")])
   OGt  -> prPrec i 0 (concatD [doc (showString ">")])
   OLt  -> prPrec i 0 (concatD [doc (showString "<")])
   OGeq  -> prPrec i 0 (concatD [doc (showString ">=")])
   OLeq  -> prPrec i 0 (concatD [doc (showString "<=")])
   OLike not -> prPrec i 0 (concatD [prt 0 not , doc (showString "LIKE")])


instance Print Typing where
  prt i e = case e of
   TColumn id type' inlineconstraints -> prPrec i 0 (concatD [prt 0 id , prt 0 type' , prt 0 inlineconstraints])
   TConstraint constraint -> prPrec i 0 (concatD [prt 0 constraint])
   TNamedConstraint id constraint -> prPrec i 0 (concatD [doc (showString "CONSTRAINT") , prt 0 id , prt 0 constraint])

  prtList es = case es of
   [x] -> (concatD [prt 0 x])
   x:xs -> (concatD [prt 0 x , doc (showString ",") , prt 0 xs])

instance Print InlineConstraint where
  prt i e = case e of
   ICPrimaryKey  -> prPrec i 0 (concatD [doc (showString "PRIMARY") , doc (showString "KEY")])
   ICReferences id0 id policys -> prPrec i 0 (concatD [doc (showString "REFERENCES") , prt 0 id0 , doc (showString "(") , prt 0 id , doc (showString ")") , prt 0 policys])
   ICUnique  -> prPrec i 0 (concatD [doc (showString "UNIQUE")])
   ICNotNull  -> prPrec i 0 (concatD [doc (showString "NOT") , doc (showString "NULL")])
   ICCheck condition -> prPrec i 0 (concatD [doc (showString "CHECK") , doc (showString "(") , prt 0 condition , doc (showString ")")])
   ICDefault exp -> prPrec i 0 (concatD [doc (showString "DEFAULT") , prt 4 exp])

  prtList es = case es of
   [] -> (concatD [])
   x:xs -> (concatD [prt 0 x , prt 0 xs])

instance Print Constraint where
  prt i e = case e of
   CPrimaryKey ids -> prPrec i 0 (concatD [doc (showString "PRIMARY") , doc (showString "KEY") , doc (showString "(") , prt 0 ids , doc (showString ")")])
   CReferences ids0 id ids policys -> prPrec i 0 (concatD [doc (showString "FOREIGN") , doc (showString "KEY") , doc (showString "(") , prt 0 ids0 , doc (showString ")") , doc (showString "REFERENCES") , prt 0 id , doc (showString "(") , prt 0 ids , doc (showString ")") , prt 0 policys])
   CUnique ids -> prPrec i 0 (concatD [doc (showString "UNIQUE") , doc (showString "(") , prt 0 ids , doc (showString ")")])
   CNotNull  -> prPrec i 0 (concatD [doc (showString "NOT") , doc (showString "NULL")])
   CCheck condition -> prPrec i 0 (concatD [doc (showString "CHECK") , doc (showString "(") , prt 0 condition , doc (showString ")")])


instance Print Type where
  prt i e = case e of
   TIdent id -> prPrec i 0 (concatD [prt 0 id])
   TSized id n -> prPrec i 0 (concatD [prt 0 id , doc (showString "(") , prt 0 n , doc (showString ")")])


instance Print Policy where
  prt i e = case e of
   PDelete action -> prPrec i 0 (concatD [doc (showString "ON") , doc (showString "DELETE") , prt 0 action])
   PUpdate action -> prPrec i 0 (concatD [doc (showString "ON") , doc (showString "UPDATE") , prt 0 action])

  prtList es = case es of
   [] -> (concatD [])
   x:xs -> (concatD [prt 0 x , prt 0 xs])

instance Print Action where
  prt i e = case e of
   ACascade  -> prPrec i 0 (concatD [doc (showString "CASCADE")])
   ASetNull  -> prPrec i 0 (concatD [doc (showString "SET") , doc (showString "NULL")])


instance Print TablePlaces where
  prt i e = case e of
   TPNone  -> prPrec i 0 (concatD [])
   TPAttributes ids -> prPrec i 0 (concatD [doc (showString "(") , prt 0 ids , doc (showString ")")])


instance Print Values where
  prt i e = case e of
   VValues exps -> prPrec i 0 (concatD [doc (showString "(") , prt 0 exps , doc (showString ")")])
   VQuery query -> prPrec i 0 (concatD [doc (showString "(") , prt 0 query , doc (showString ")")])


instance Print InsertValues where
  prt i e = case e of
   IVValues exps -> prPrec i 0 (concatD [doc (showString "VALUES") , doc (showString "(") , prt 0 exps , doc (showString ")")])
   IVQuery query -> prPrec i 0 (concatD [doc (showString "(") , prt 0 query , doc (showString ")")])


instance Print Definition where
  prt i e = case e of
   DTable id query -> prPrec i 0 (concatD [prt 0 id , doc (showString "AS") , doc (showString "(") , prt 0 query , doc (showString ")")])

  prtList es = case es of
   [x] -> (concatD [prt 0 x])
   x:xs -> (concatD [prt 0 x , doc (showString ",") , prt 0 xs])

instance Print Alteration where
  prt i e = case e of
   AAdd typing -> prPrec i 0 (concatD [doc (showString "ADD") , prt 0 typing])
   ADrop id -> prPrec i 0 (concatD [doc (showString "DROP") , doc (showString "COLUMN") , prt 0 id])
   AAlter id type' -> prPrec i 0 (concatD [doc (showString "MODIFY") , doc (showString "COLUMN") , prt 0 id , prt 0 type'])
   ADropPrimaryKey  -> prPrec i 0 (concatD [doc (showString "DROP") , doc (showString "PRIMARY") , doc (showString "KEY")])
   ADropConstraint id -> prPrec i 0 (concatD [doc (showString "DROP") , doc (showString "CONSTRAINT") , prt 0 id])

  prtList es = case es of
   [x] -> (concatD [prt 0 x])
   x:xs -> (concatD [prt 0 x , doc (showString ",") , prt 0 xs])

instance Print TriggerTime where
  prt i e = case e of
   TTBefore  -> prPrec i 0 (concatD [doc (showString "BEFORE")])
   TTAfter  -> prPrec i 0 (concatD [doc (showString "AFTER")])
   TTInstead  -> prPrec i 0 (concatD [doc (showString "INSTEAD") , doc (showString "OF")])


instance Print TriggerAction where
  prt i e = case e of
   TAUpdate  -> prPrec i 0 (concatD [doc (showString "UPDATE")])
   TAInsert  -> prPrec i 0 (concatD [doc (showString "INSERT")])
   TADelete  -> prPrec i 0 (concatD [doc (showString "DELETE")])

  prtList es = case es of
   [x] -> (concatD [prt 0 x])
   x:xs -> (concatD [prt 0 x , doc (showString "OR") , prt 0 xs])

instance Print TriggerEach where
  prt i e = case e of
   TERow  -> prPrec i 0 (concatD [doc (showString "ROW")])
   TEStatement  -> prPrec i 0 (concatD [doc (showString "STATEMENT")])


instance Print TriggerBody where
  prt i e = case e of
   TBStatements triggerstatements -> prPrec i 0 (concatD [doc (showString "BEGIN") , prt 0 triggerstatements , doc (showString "END")])
   TBProcedure id -> prPrec i 0 (concatD [doc (showString "EXECUTE") , doc (showString "PROCEDURE") , prt 0 id])


instance Print TriggerStatement where
  prt i e = case e of
   TSStatement statement -> prPrec i 0 (concatD [prt 0 statement])
   TSIfThen condition triggerstatements triggerelses -> prPrec i 0 (concatD [doc (showString "IF") , doc (showString "(") , prt 0 condition , doc (showString ")") , doc (showString "THEN") , prt 0 triggerstatements , prt 0 triggerelses , doc (showString "END") , doc (showString "IF")])
   TSException str -> prPrec i 0 (concatD [doc (showString "RAISE") , doc (showString "EXCEPTION") , prt 0 str])

  prtList es = case es of
   [] -> (concatD [])
   x:xs -> (concatD [prt 0 x , doc (showString ";") , prt 0 xs])

instance Print TriggerElse where
  prt i e = case e of
   TEElseIf condition triggerstatements -> prPrec i 0 (concatD [doc (showString "ELSE") , doc (showString "IF") , doc (showString "(") , prt 0 condition , doc (showString ")") , doc (showString "THEN") , prt 0 triggerstatements])

  prtList es = case es of
   [] -> (concatD [])
   x:xs -> (concatD [prt 0 x , doc (showString ";") , prt 0 xs])



module AbsRelAlgebra where

-- Haskell module generated by the BNF converter


newtype Ident = Ident String deriving (Eq,Ord,Show)
data Rels =
   RRels [Rel]
  deriving (Eq,Ord,Show)

data Rel =
   RTable Ident
 | RSelect Cond Rel
 | RProject [Exp] Rel
 | RRename Renaming Rel
 | RGroup [Ident] [Aggregation] Rel
 | RSort [Ident] Rel
 | RDistinct Rel
 | RUnion Rel Rel
 | RJoin Rel Rel
 | RThetaJoin Rel Cond Rel
 | RIntersect Rel Rel
 | RCartesian Rel Rel
 | RExcept Rel Rel
  deriving (Eq,Ord,Show)

data Cond =
   CEq Exp Exp
 | CNEq Exp Exp
 | CLt Exp Exp
 | CGt Exp Exp
 | CLike Exp Exp
 | CNot Cond
 | CAnd Cond Cond
 | COr Cond Cond
  deriving (Eq,Ord,Show)

data Exp =
   EIdent Ident
 | EString String
 | EInt Integer
 | EFloat Double
 | EAggr Function Ident
 | EMul Exp Exp
 | EDiv Exp Exp
 | EAdd Exp Exp
 | ESub Exp Exp
  deriving (Eq,Ord,Show)

data Renaming =
   RRelation Ident
 | RAttributes Ident [Ident]
 | RReplace Ident Ident
  deriving (Eq,Ord,Show)

data Aggregation =
   AgFun Function Ident Exp
  deriving (Eq,Ord,Show)

data Function =
   FAvg
 | FSum
 | FMax
 | FMin
 | FCount
  deriving (Eq,Ord,Show)


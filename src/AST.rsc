module AST


/*
 * Define Abstract Syntax for QL
 *
 * - complete the following data types
 * - make sure there is an almost one-to-one correspondence with the grammar
 */

data AForm(loc src = |tmp:///|)
  = form(str name, list[AQuestion] questions)
  ; 

data AQuestion(loc src = |tmp:///|) =
      question(str label, AId id, AType atype)
    | computedQuestion(str label, AId id, AType atype, AExpr expr)
    | ifQuestion(AExpr expr, AQuestion question)
    | ifElseQuestion(AExpr expr, AQuestion question, AQuestion elseQuestion)
    | questionBlock(list[AQuestion] questions)
  ; 

data AExpr(loc src = |tmp:///|)
  = ref(AId id) 
    | add(AExpr lhs, AExpr rhs)
    | sub(AExpr lhs, AExpr rhs)
    | mul(AExpr lhs, AExpr rhs)
    | div(AExpr lhs, AExpr rhs)
    | neg(AExpr expr)
    | pos(AExpr expr)
    | eq(AExpr lhs, AExpr rhs)
    | neq(AExpr lhs, AExpr rhs)
    | lt(AExpr lhs, AExpr rhs)
    | lte(AExpr lhs, AExpr rhs)
    | gt(AExpr lhs, AExpr rhs)
    | gte(AExpr lhs, AExpr rhs)
    | and(AExpr lhs, AExpr rhs)
    | or(AExpr lhs, AExpr rhs)
    | \int(int i)
    | \bool(bool b)
    | \str(str s)
  ;




data AId(loc src = |tmp:///|)
  = id(str name);

data AType(loc src = |tmp:///|)
    = atype(str atype)
  ;

module Check

import AST;
import Resolve;
import Message; // see standard library

data Type
  = tint()
  | tbool()
  | tstr()
  | tunknown()
  ;

// the type environment consisting of defined questions in the form 
alias TEnv = rel[loc def, str name, str label, Type \type];

// To avoid recursively traversing the form, use the `visit` construct
// or deep match (e.g., `for (/question(...) := f) {...}` ) 
TEnv collect(AForm f) {
    TEnv tenv = {};
    visit (f) {
        case question(str l,AId id, AType t): tenv += {<f.src, id.name, l, t>};
        case computedQuestion(str l,AId id, AType t, AExpr e): tenv += {<f.src, id.name, l, t>};
        case ifQuestion(AExpr e, AQuestion q): tenv += collect(q);
        case ifElseQuestion(AExpr e, AQuestion q1, AQuestion q2): tenv += collect(q1) + collect(q2);
        case questionBlock(list[AQuestion] qs): tenv += {collect(q) | q <- qs};
    }
  return tenv; 
}

TEnv collect(AQuestion q) {
    TEnv tenv = {};
    visit (q) {
        case question(str l,AId id, AType t): tenv += {<q.src, id.name, l, t>};
        case computedQuestion(str l,AId id, AType t, AExpr e): tenv += {<q.src, id.name, l, t>};
        case ifQuestion(AExpr e, AQuestion q): tenv += collect(q);
        case ifElseQuestion(AExpr e, AQuestion q1, AQuestion q2): tenv += collect(q1) + collect(q2);
        case questionBlock(list[AQuestion] qs): tenv += {collect(q) | q <- qs};
    }
  return tenv; 
}

set[Message] check(AForm f, TEnv tenv, UseDef useDef) {
  return {checkedQuestion | q<-f.questions,checkedQuestion<- check(q,tenv,useDef)};; 
}

// - produce an error if there are declared questions with the same name but different types.
// - duplicate labels should trigger a warning 
// - the declared type computed questions should match the type of the expression.
set[Message] check(AQuestion q, TEnv tenv, UseDef useDef) {
    set[Message] msgs = {};
    visit (q) {
        case question(str l,AId id, AType t): 
            if (<q.src, id.name, l, Type t2> in tenv) {
               
                
            };
    }
  return msgs; 
}

// Check operand compatibility with operators.
// E.g. for an addition node add(lhs, rhs), 
//   the requirement is that typeOf(lhs) == typeOf(rhs) == tint()
set[Message] check(AExpr e, TEnv tenv, UseDef useDef) {
  set[Message] msgs = {};
  
  switch (e) {
    case ref(AId x):
      msgs += { error("Undeclared question", x.src) | useDef[x.src] == {} };

    // etc.
  }
  
  return msgs; 
}

Type typeOf(AExpr e, TEnv tenv, UseDef useDef) {
  switch (e) {
    case ref(id(_, src = loc u)):  
      if (<u, loc d> <- useDef, <d, x, _, Type t> <- tenv) {
        return t;
      }
    // etc.
  }
  return tunknown(); 
}

/* 
 * Pattern-based dispatch style:
 * 
 * Type typeOf(ref(id(_, src = loc u)), TEnv tenv, UseDef useDef) = t
 *   when <u, loc d> <- useDef, <d, x, _, Type t> <- tenv
 *
 * ... etc.
 * 
 * default Type typeOf(AExpr _, TEnv _, UseDef _) = tunknown();
 *
 */
 
 


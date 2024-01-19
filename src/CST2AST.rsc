module CST2AST

import Syntax;
import AST;
import String;
import Boolean;

import ParseTree;

/*
 * Implement a mapping from concrete syntax trees (CSTs) to abstract syntax trees (ASTs)
 *
 * - Use switch to do case distinction with concrete patterns (like in Hack your JS) 
 * - Map regular CST arguments (e.g., *, +, ?) to lists 
 *   (NB: you can iterate over * / + arguments using `<-` in comprehensions or for-loops).
 * - Map lexical nodes to Rascal primitive types (bool, int, str)
 * - See the ref example on how to obtain and propagate source locations.
 */

AForm cst2ast(start[Form] sf) {
  Form f = sf.top; // remove layout before and after form
  list[AQuestion] qs = [ cst2ast(q) | q <- f.questions ];
  

  return form("<f.name>", qs, src=f.src); 
}

default AQuestion cst2ast(Question q) {
  switch (q) {
    case (Question)`<Str s> <Id x> : <Type t>`: 
        return question("<s>", id("<x>", src=x.src), cst2ast(t), src=q.src);

    case (Question)`<Str s> <Id x> : <Type t> = <Expr e>`: 
        return computedQuestion("<s>", id("<x>", src=x.src), cst2ast(t), cst2ast(e), src=q.src);

    case (Question)`{ <Question* questions> }`:
        return questionBlock([ cst2ast(q) | q <- questions ], src=q.src);

    case (Question)`if (<Expr e>) then <Question q>`:
        return ifQuestion(cst2ast(e), cst2ast(q), src=q.src);

    case (Question)`if (<Expr e>) then <Question q1> else <Question q2>`:
        return ifElseQuestion(cst2ast(e), cst2ast(q1), cst2ast(q2), src=q.src);

    default: throw "Unhandled question: <q>";
  }
}

AExpr cst2ast(Expr e) {
  switch (e) {
    case (Expr)`<Id x>`: return ref(id("<x>", src=x.src), src=x.src);
    case (Expr)`<Int i>`: return \int(toInt("<i>"), src=i.src);
    case (Expr)`<Bool b>`: return \bool(fromString("<b>"), src=b.src);
    case (Expr)`<Str s>`: return \str("<s>", src=s.src);
    case (Expr)`<Expr e1> + <Expr e2>`: return add(cst2ast(e1), cst2ast(e2), src=e.src);
    case (Expr)`<Expr e1> - <Expr e2>`: return sub(cst2ast(e1), cst2ast(e2), src=e.src);
    case (Expr)`<Expr e1> * <Expr e2>`: return mul(cst2ast(e1), cst2ast(e2), src=e.src);
    case (Expr)`<Expr e1> / <Expr e2>`: return div(cst2ast(e1), cst2ast(e2), src=e.src);
    case (Expr)`<Expr e1> == <Expr e2>`: return eq(cst2ast(e1), cst2ast(e2), src=e.src);
    case (Expr)`<Expr e1> != <Expr e2>`: return neq(cst2ast(e1), cst2ast(e2), src=e.src);
    case (Expr)`<Expr e1> \< <Expr e2>`: return lt(cst2ast(e1), cst2ast(e2), src=e.src);
    case (Expr)`<Expr e1> \<= <Expr e2>`: return lte(cst2ast(e1), cst2ast(e2), src=e.src);
    case (Expr)`<Expr e1> \> <Expr e2>`: return gt(cst2ast(e1), cst2ast(e2), src=e.src);
    case (Expr)`<Expr e1> \>= <Expr e2>`: return gte(cst2ast(e1), cst2ast(e2), src=e.src);
    case (Expr)`<Expr e1> and <Expr e2>`: return and(cst2ast(e1), cst2ast(e2), src=e.src);
    case (Expr)`<Expr e1> or <Expr e2>`: return or(cst2ast(e1), cst2ast(e2), src=e.src);
    case (Expr)`!<Expr e>`: return neg(cst2ast(e), src=e.src);


    
    default: throw "Unhandled expression: <e>";
  }
}

default AType cst2ast(Type t) {
  return atype("<t>", src=t.src);
}

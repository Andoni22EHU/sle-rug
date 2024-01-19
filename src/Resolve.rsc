module Resolve

import AST;

/*
 * Name resolution for QL
 */ 

// modeling declaring occurrences of names
alias Def = rel[str name, loc def];

// modeling use occurrences of names
alias Use = rel[loc use, str name];

alias UseDef = rel[loc use, loc def];

// the reference graph
alias RefGraph = tuple[Use uses, Def defs, UseDef useDef];

RefGraph resolve(AForm f) = <us, ds, us o ds>
  when Use us := uses(f), Def ds := defs(f);

Use uses(AForm f) {
  list[Use] questionUses = [uses(q) | q <- f.questions];
  return { use | uses <- questionUses };
}

Def defs(AForm f) {
  list[Def] questionDefs = [defs(q) | q <- f.questions];
  return { def | defs <- questionDefs };
}

Use uses(AQuestion q) {
  switch (q) {
    case question(_, id, _): return { <id.src, id.name> };
    case computedQuestion(_, id, _, expr): return uses(expr) + { <id.src, id.name> };
    case ifQuestion(expr, question): return uses(expr) + uses(question);
    case ifElseQuestion(expr, ifQuestion, elseQuestion): return uses(expr) + uses(ifQuestion) + uses(elseQuestion);
    case questionBlock(questions): return { use | q <- questions, use <- uses(q) };
    default: return {};

  }
}

Def defs(AQuestion q) {
  switch (q) {
    case question(_, id, _): return { <id.name, id.src> };
    case computedQuestion(_, id, _, _): return { <id.name, id.src> };
    case ifQuestion(_, question): return defs(question);
    case ifElseQuestion(_, ifQuestion, elseQuestion): return defs(ifQuestion) + defs(elseQuestion);
    case questionBlock(questions): return { def | q <- questions, def <- defs(q) };
    default: return {};
  }
}

Use uses(AExpr e) {
  switch (e) {
    case ref(id): return { <id.src, id.name> };
    case add(lhs, rhs): return uses(lhs) + uses(rhs);
    case sub(lhs, rhs): return uses(lhs) + uses(rhs);
    // Add cases for other expressions
    default: return {};
  }
}

Def defs(AExpr e) {
  // For expressions, there are no defining occurrences of names.
  return {};
}

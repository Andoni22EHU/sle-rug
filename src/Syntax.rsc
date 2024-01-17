module Syntax

extend lang::std::Layout;
extend lang::std::Id;



/*
 * Concrete syntax of QL
 */

start syntax Form 
  = "form" Id name "{" Question* questions "}"; 

// TODO: question, computed question, block, if-then-else, if-then
syntax Question =  
    Str label Id id ":" Type type // simple question
    | Str label Id id ":" Type type "=" Expr expr // computed question
    | "{" Question* questions "}" // block
    | "if" "(" Expr expr ")" Question question // if-then
    | "if" "(" Expr expr ")" Question question "else" Question question // if-then-else
    ;

// TODO: +, -, *, /, &&, ||, !, >, <, <=, >=, ==, !=, literals (bool, int, str)
// Think about disambiguation using priorities and associativity
// and use C/Java style precedence rules (look it up on the internet)
syntax Expr 
  = Id
    | Int
    | Bool
    | Str
  > left Expr "+" Expr    // addition is left-associative.
  > left Expr "-" Expr    // subtraction is left-associative.
  > left Expr "*" Expr    // multiplication is left-associative.
  > left Expr "/" Expr    // division is left-associative.
  > left Expr "&&" Expr   // logical AND is left-associative.
  > left Expr "||" Expr   // logical OR is left-associative.
  > right "!" Expr        // logical NOT is right-associative.
  > non-assoc Expr "\>" Expr // comparison operators are non-associative.
  > non-assoc Expr "\<" Expr
  > non-assoc Expr "\<=" Expr
  > non-assoc Expr "\>=" Expr
  > non-assoc Expr "!=" Expr
  > non-assoc Expr "==" Expr
  | "(" Expr ")"          // parentheses can be used to override precedence and associativity.
  ;
  
syntax Type = "boolean" | "integer" | "string";

lexical Str = 
  [\"] ![\"]* [\"]; // slightly simplified

lexical Int 
  = [0-9]+;

lexical Bool =
   "true" 
   | "false"
  ;




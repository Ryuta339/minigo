package main

import "fmt"
import (
	"os"
)

var debugMode = false

type Token struct {
	typ   string
	sval  string
}

type Ast struct {
	typ     string
	// int
	ival    int
	// unary
	operand *Ast
	// binop
	op string
	left    *Ast
	right   *Ast
	// string
	sval   string
	slabel string
	// funcall
	fname string
	args []*Ast
	// compound stmt
	stmts []*Ast
}

func debugPrint(s string) {
	fmt.Fprintf(os.Stderr, "# %s\n", s)
}

func debugPrintVar(name string, v interface{}) {
	debugPrint(fmt.Sprintf("%s=%v", name, v))
}

func debugToken(tok *Token) {
	debugPrint(fmt.Sprintf("tok: type=%-8s, sval=\"%s\"", tok.typ, tok.sval))
}

func debugAst(name string, ast *Ast) {
	switch ast.typ {
	case "funcall":
		debugPrintVar("funcall", ast)
		for _, arg := range ast.args {
			debugPrintVar("arg", arg)
		}
	case  "int" :
		debugPrintVar(name, fmt.Sprintf("%d", ast.ival))
	case "uop" :
		debugAst(name, ast.operand)
	case "binop" :
		debugPrintVar("ast.binop", ast.typ)
		debugAst("left", ast.left)
		debugAst("right", ast.right)
	}
}

func errorf(format string, v ...interface{}) {
	s := fmt.Sprintf(format, v...)
	panic(s)
}

func assert(cond bool, msg string) {
	if !cond {
		panic(fmt.Sprintf("assertion failed: %s", msg))
	}
}


func main() {
	debugMode = true

	var sourceFile string
	if len(os.Args) > 1 {
		sourceFile = os.Args[1] + ".go"
	} else {
		sourceFile = "/dev/stdin"
	}

	// tokenize
	tokens := tokenizeFromFile(sourceFile)
	assert(len(tokens) > 0, "tokens should have length")

	if debugMode {
		renderTokens(tokens)
	}

	t := &TokenStream{
		tokens: tokens,
		index: 0,
	}
	// parse
	ast := parse(t)

	if debugMode {
		debugPrint("==== Dump Ast ===")
		debugAst("root", ast)
	}

	// generate
	generate(ast)
}

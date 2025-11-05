all: interpretador compilador codigo
	echo "=== Execução ==="
	./interpretador < codigo

codigo: compilador entrada.txt
	./compilador < entrada.txt > codigo
	echo "=== Codigo ==="
	cat codigo

compilador: lex.yy.c y.tab.c
	g++ y.tab.c -o compilador -lfl

lex.yy.c: mini_js.l
	lex mini_js.l

y.tab.c: mini_js.y
	yacc mini_js.y

interpretador: lex.yy.mdp.o var_object.cc mdp.h mdp.cc
	g++ -Wall -std=c++17 lex.yy.mdp.o mdp.cc -ll -lfl -o interpretador

lex.yy.mdp.o: lex.yy.mdp.c
	g++ -Wall -std=c++14 -c lex.yy.mdp.c

lex.yy.mdp.c: mdp.l
	lex -o lex.yy.mdp.c mdp.l

clean:
	rm -f lex.yy.c y.tab.c y.tab.h compilador codigo lex.yy.mdp.c lex.yy.mdp.o interpretador

.PHONY: all clean
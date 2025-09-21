all: saida entrada.txt
	./saida < entrada.txt

lex.yy.c: tradutor.l
	lex tradutor.l

saida: lex.yy.c
	g++ -std=c++17 lex.yy.c -o saida -ll
	
clean:
	rm saida lex.yy.c
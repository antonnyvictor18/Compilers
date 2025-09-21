all: saida entrada.txt
	./saida < entrada.txt

lex.yy.c: scan.lex
	flex scan.lex

saida: lex.yy.c main.cc 
	g++ -std=c++17 main.cc -o saida -lfl
	
clean:
	rm -f saida lex.yy.c
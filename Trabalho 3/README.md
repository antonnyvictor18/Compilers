# Compilador de Mini JavaScript

**Autor:** Antonny Victor  
**Disciplina:** Compiladores  
**Instituição:** UFRJ/PESC

## Descrição

Compilador para um subconjunto da linguagem JavaScript que gera código intermediário para uma máquina de pilha.

## Como Usar

### Opção 1: Com Make (Linux/WSL)

```bash
# Compilar e executar
make

# Limpar arquivos gerados
make clean
```

### Opção 2: Com Docker

```bash
# Construir a imagem
docker build -t trabalho3 .

# Executar
docker run -v $(pwd):/trabalho3 trabalho3
```

### Opção 3: Manual

```bash
# Compilar interpretador da máquina de pilha
lex -o lex.yy.mdp.c mdp.l
g++ -Wall -std=c++14 -c lex.yy.mdp.c
g++ -Wall -std=c++17 lex.yy.mdp.o mdp.cc -ll -lfl -o interpretador

# Compilar o compilador
lex mini_js.l
yacc mini_js.y
g++ y.tab.c -o compilador -lfl

# Gerar código intermediário
./compilador < entrada.txt > codigo

# Executar na máquina de pilha
./interpretador < codigo
```

## Estrutura do Projeto

- `mini_js.l` - Analisador Léxico
- `mini_js.y` - Analisador Sintático e Gerador de Código
- `mdp.l`, `mdp.cc`, `mdp.h`, `var_object.cc` - Interpretador da Máquina de Pilha
- `entrada.txt` - Arquivo de entrada com código Mini JavaScript
- `Makefile` - Automatização da compilação
- `Dockerfile` - Container Docker

## Exemplo

**Entrada (`entrada.txt`):**
```javascript
let a = 4, b = 5, c, d;
if( a++ > b )
  c = "a e' maior" + "!";
if( a < b + 1 )
  d = "a e' menor";
```

**Saída:**
```
=== Console ===
=== Vars ===
|{ a: 5; b: 5; c: undefined; d: a e' menor; undefined: undefined; }|
=== Pilha ===
```

## Funcionalidades

- Declarações: `let`, `var`, `const`
- Estruturas de controle: `if`, `else`, `for`, `while`
- Operadores aritméticos, relacionais e lógicos
- Arrays e objetos
- Strings e números
- Validação semântica (variáveis não declaradas, const, etc)

## Créditos

Desenvolvido como trabalho da disciplina de Compiladores (UFRJ/PESC).

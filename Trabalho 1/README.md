## Trabalho 1 – Primeiro Analisador Léxico

Lexical analyzer written with Flex. It recognizes identifiers, numbers, strings (with escapes), comparison operators, comments, and more. The C++ driver (`main.cc`) calls the generated scanner and prints token codes with their lexemes.

### Build (local)
```bash
make
```
This will:
- run `flex scan.lex` to generate `lex.yy.c`
- compile the driver and link with `-lfl` to produce `saida`

### Run
```bash
./saida < entrada.txt
```

### Clean
```bash
make clean
```

### Build with Docker
```bash
docker build -t trabalho1 -f Dockerfile .
docker run --rm -v "$PWD":/trabalho1 -w /trabalho1 trabalho1
```
The container runs `make` as its entrypoint.



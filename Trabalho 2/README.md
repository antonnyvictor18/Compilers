## Trabalho 2 – Gerador de Forma Intermediária

Translator implemented with Flex + C++. It tokenizes input and prints an intermediate/postfix representation for expressions and simple statements (assignments and `print`).

### Build (local)
```bash
make
```
This will:
- run `lex tradutor.l` to generate `lex.yy.c`
- compile and link with `-ll` to produce `saida`

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
docker build -t trabalho2 -f Dockerfile .
docker run --rm -v "$PWD":/trabalho2 -w /trabalho2 trabalho2
```
The container runs `make` as its entrypoint.



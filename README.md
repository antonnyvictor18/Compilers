## Compilers – College Homeworks

This repository stores assignments for a Compilers course. Each homework lives in its own folder and can be built either locally (with Make + Flex) or inside Docker.

### Repository layout
- `Trabalho 1/` – Lexical analyzer (Flex) with a small C++ driver
- `Trabalho 2/` – Scanner/parser-like translator generating intermediate/postfix code (Flex + C++)

### Prerequisites (local build)
- Linux/macOS or Windows with WSL
- `make`, `g++`
- `lex`, `libfl-dev` (or platform equivalent providing the `-ll` library)

If you prefer isolation, use the provided Dockerfiles instead (they install everything needed).

### Quick start
Build and run each homework locally:

```bash
cd "Trabalho 1" && make && ./saida < entrada.txt
cd "Trabalho 2" && make && ./saida < entrada.txt
```

Using Docker (example for Trabalho 1):

```bash
docker build -t trabalho1 -f "Trabalho 1/Dockerfile" .
docker run --rm -v "$PWD/Trabalho 1":/trabalho1 -w /trabalho1 trabalho1
```

The container entrypoint runs `make`, so it will build (and, for targets where `all` runs the program, also execute using `entrada.txt`).

### Continuous Integration
A GitHub Actions workflow builds both homeworks on every push/PR. It installs Flex and the `-ll` development library and runs `make` inside each folder.

### Notes
- Outputs are printed to stdout; sample inputs are provided as `entrada.txt` in each folder.
- Use `make clean` in each folder to remove generated files.
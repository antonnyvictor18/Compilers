%{
#include <iostream>
#include <string>
#include <map>
#include <cstdlib>

using namespace std;

string lexema;
int token;

void match_token(int expected);
void parse_program();
void parse_statement();
void parse_expression();
void parse_expression_tail();
void parse_term();
void parse_term_tail();
void parse_unary();
void parse_power();
void parse_power_tail();
void parse_factorial();
void parse_factorial_tail();
void parse_factor();
void parse_function_args();

enum TokenType {
    ID = 256,
    NUMBER,
    PRINT,
    FLOAT,
    STRING,
    FUNCTION
};

map<int, string> token_names = {
    { ID,       "identificador"},
    { NUMBER,      "numero"},
    { PRINT,    "print"},
    { FLOAT,    "float"},
    { STRING,   "string"},
    { FUNCTION, "function"}
};

%}

WS          [ \n\r\t]
LETTER      [A-Za-z_]
DIGIT       [0-9]
ID          {LETTER}({LETTER}|{DIGIT})*
INTEGER     {DIGIT}+
FLOAT       {INTEGER}([.]{INTEGER})?([eE][+-]?{INTEGER})?
ESCAPING    ["][^"]*([\\]|["])["][^"]*["]|['][^']*([\\]|['])['][^']*[']
STRING      (\"([^\"\n]*)\")|{ESCAPING}  
OPEN_PAREN    "("

%%

{WS}               {                                }
"print"            { lexema = yytext; return PRINT; }
{INTEGER}          { lexema = yytext; return NUMBER; }
{FLOAT}            { lexema = yytext; return FLOAT; }
{STRING}           { lexema = yytext; return STRING; }
{ID}/{OPEN_PAREN}  { lexema = yytext; return FUNCTION; }
{ID}               { lexema = yytext; return ID; }
.                  { return yytext[0]; }

%%

string get_token_name(int token) {
    if (token_names.find(token) != token_names.end()) {
        return token_names[token];
    } else {
        return string(1, (char)token);
    }
}

int get_next_token() {
    return yylex();
}

void match_token(int expected) {
    if (token == expected) {
        token = get_next_token();
    } else {
        cout << "Erro: esperado " << get_token_name(expected) 
             << ", encontrado " << get_token_name(token) << endl;
        exit(1);
    }
}


void parse_program() {
    parse_statement();
    if (token == ';') {
        match_token(';');
        parse_program();
    }
}

void parse_statement() {
    switch (token) {
        case PRINT:
            match_token(PRINT);
            parse_expression();
            cout << "print #" << " ";
            break;
        case ID:
            cout << lexema << " ";
            match_token(ID);
            match_token('=');
            parse_expression();
            cout << "= ^" << " ";
            break;
    }
}

void parse_expression() {
    parse_term();
    parse_expression_tail();
}

void parse_expression_tail() {
    switch (token) {
        case '+':
            match_token('+');
            parse_term();
            cout << "+ ";
            parse_expression_tail();
            break;
        case '-':
            match_token('-');
            parse_term();
            cout << "- ";
            parse_expression_tail();
            break;
    }
}

void parse_term() {
    parse_unary();
    parse_term_tail();
}

void parse_term_tail() {
    switch (token) {
        case '*':
            match_token('*');
            parse_unary();
            cout << "* ";
            parse_term_tail();
            break;
        case '/':
            match_token('/');
            parse_unary();
            cout << "/ ";
            parse_term_tail();
            break;
    }
}

void parse_unary() {
    switch (token) {
        case '-':
            cout << "0 ";
            match_token('-');
            parse_unary();
            cout << "- ";
            break;
        case '+':
            match_token('+');
            parse_unary();
            break;
        default:
            parse_power();
            //break;
    }
}

void parse_power() {
    parse_factorial();
    parse_power_tail();
}

void parse_power_tail() {
    if (token == '^') {
        match_token('^');
        parse_power();
        cout << "power # ";
    }
}

void parse_factorial() {
    parse_factor();
    parse_factorial_tail();
}

void parse_factorial_tail() {
    if (token == '!') {
        match_token('!');
        cout << "fat # ";
        parse_factorial_tail();
    }
}

void parse_function_args() {
    parse_expression();
    if (token == ',') {
        match_token(',');
        parse_function_args();
    }
}

void parse_factor() {
    string saved_lexeme = lexema;
    
    switch (token) {
        case ID:
            cout << lexema << " @ ";
            match_token(ID);
            break;
        case NUMBER:
            cout << lexema << " ";
            match_token(NUMBER);
            break;
        case FLOAT:
            cout << lexema << " ";
            match_token(FLOAT);
            break;
        case STRING:
            cout << lexema << " ";
            match_token(STRING);
            break;
        case FUNCTION:
            match_token(FUNCTION);
            match_token('(');
            parse_function_args();
            match_token(')');
            cout << saved_lexeme << " # ";
            break;
        case '(':
            match_token('(');
            parse_expression();
            match_token(')');
            break;
    }
}

int main() {
    token = get_next_token();
    parse_program();
    cout << endl;
    return 0;
}


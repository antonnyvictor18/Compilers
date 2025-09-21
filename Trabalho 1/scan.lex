%{

#include <iostream>
#include <string>

using namespace std;

string lexema;

string strip_quotes(const string &s) {
    if (s.size() < 2) return "";
    return s.substr(1, s.size() - 2);
}

string normalize_string_literal(const string &s) {
    if (s.size() < 2) return "";
    string out;
    size_t i = 1;                     
    size_t end = s.size() - 1;
    char quote_char = s[0];  // Remember the opening quote character
    
    while (i < end) {
        char c = s[i];
        if (c == '\\') {
            if (i + 1 < end) {
                char nxt = s[i + 1];
                switch (nxt) {
                    case '\\': 
                        out.push_back('\\');
                        out.push_back('\\');
                        break;
                    case 'n':  
                        out.push_back('\\');
                        out.push_back('n');
                        break; 
                    case 't':  
                        out.push_back('\\');
                        out.push_back('t');
                        break; 
                    case '\'': out.push_back('\''); break;
                    case '\"': out.push_back('\"'); break;
                    default:
                        out.push_back('\\');
                        out.push_back(nxt);
                }
                i += 2;
                continue;
            } else {
                out.push_back('\\');
                i++;
                continue;
            }
        } else if (c == '\'' && quote_char == '\'') {
            if (i + 1 < end && s[i + 1] == '\'') {
                out.push_back('\'');
                i += 2;
                continue;
            } else {
                out.push_back('\'');
                i++;
                continue;
            }
        } else if (c == '"' && quote_char == '"') {
            if (i + 1 < end && s[i + 1] == '"') {
                out.push_back('"');
                i += 2;
                continue;
            } else {
                out.push_back('"');
                i++;
                continue;
            }
        } else {
            out.push_back(c);
            i++;
        }
    }
    return out;
}
%}

DIG           [0-9]
ALPHA         [A-Za-z]
INTNUM        {DIG}+
UND            "_"
DOLLAR         "$"
STRING        (\"([^\"\n]*)\")
SSTRING       ('([^'\n]*)')
ID            ({DOLLAR})({ALPHA}|{UND})({ALPHA}|{DIG}|{UND})*|({ALPHA}|{UND})({ALPHA}|{DIG}|{UND})*|({DOLLAR})
FLOAT         [-+]?{DIG}*\.?{DIG}+([eE][-+]?{DIG}+)?
BADID         ({ALPHA}|{UND}|{DOLLAR}|{DIG})({UND}|{ALPHA}|{DOLLAR}|{DIG})*
BACKTICK      [`][^`{}]*[`]
ESCAPING      ["][^"]*([\\]|["])["][^"]*["]|['][^']*([\\]|['])['][^']*[']
START         [`][^`{}]*{DOLLAR}
EXPR          [{][^}]*[}]
END           [^`{}]*[`]
COMMENT_BLOCK   \/\*\s*([^*]*\*[^\/]*)\\*\/
COMMENT_LINE    [/][/].*

%%

[ \t\r\n]            { }
"=="                 { lexema = yytext; return _IG; }
"if"                 { lexema = yytext; return _IF; }
"!="                 { lexema = yytext; return _DIF; }
"for"                { lexema = yytext; return _FOR; }
"<="                 { lexema = yytext; return _MEIG; }
">="                 { lexema = yytext; return _MAIG; }

{INTNUM}             { lexema = yytext; return _INT; }
{FLOAT}              { lexema = yytext; return _FLOAT; }

{ESCAPING}           { lexema = yytext; lexema = normalize_string_literal(lexema); return _STRING; }
{STRING}             { lexema = yytext; lexema = normalize_string_literal(lexema); return _STRING; }
{SSTRING}            { lexema = yytext; lexema = normalize_string_literal(lexema); return _STRING; }
{BACKTICK}           { lexema = yytext; lexema = strip_quotes(lexema); return _STRING2; }


{START}              { lexema = yytext; lexema = strip_quotes(lexema); return _STRING2; }
{EXPR}               { 
                        lexema = yytext; 
                        lexema = lexema.substr(1, lexema.size() - 2); 
                        return _EXPR; 
                      }
{END}                { lexema = yytext; lexema = lexema.substr(0, lexema.size() - 1); return _STRING2; }


{COMMENT_BLOCK}      { lexema = yytext; return _COMENTARIO; }
{COMMENT_LINE}       { lexema = yytext; return _COMENTARIO; }

{ID}                 { lexema = yytext; return _ID; }
{BADID}              { lexema = yytext; cout << "Erro: Identificador invalido: " << lexema << endl; }

.                    { lexema = yytext; return yytext[0]; }

%%
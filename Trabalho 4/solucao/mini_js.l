%{
#include <string>
#include <vector>
#include <algorithm>

using namespace std;

int token( int tk );

string trim( string s, const char* t = " \t\n\r\f\v{}" ) {
  s.erase(0, s.find_first_not_of(t));
  s.erase(s.find_last_not_of(t) + 1);
  
  return s;
}

vector<string> tokeniza( string asmLine ) {
  vector<string> instructions;
  string word = "";
  for( auto c : asmLine ) {
    if( c != ' ' )
      word = word + c;
    else {
      if( word.size() > 0 )
        instructions.push_back( word );
      word = "";
    }
  }
  if( word.size() > 0 )
    instructions.push_back( word );
  return instructions;
}

%}

ID      {LETRA}({LETRA}|{DIGITO})*
INT     {DIGITO}+
LETRA   [A-Za-z_]
DIGITO  [0-9]
BOOL    "true"|"false"
STRING  (\"([^\"\n]|(\\\")|\"\")+\")|(\'([^\'\n]|(\\\')|\'\')+\')
DOUBLE  {DIGITO}+"."{DIGITO}+([Ee][+\-]?{DIGITO}+)?
ASM     "asm{"[^}]*"}"

%%

"\t"        { coluna += 4;                }
" "         { coluna++;                   }
"\n"        { linha++; coluna = 1;        }
"{}"        { return token( OBJ );        }
"[]"        { return token( ARRAY );      }
"&&"        { return token( AND );        }
"||"        { return token( OR );         }
"<="        { return token( ME_IG );      }
">="        { return token( MA_IG );      }
"!="        { return token( DIF );        }
"=="        { return token( IGUAL );      }
"+="        { return token( MAIS_IGUAL ); }
"++"        { return token( MAIS_MAIS );  }
"--"        { return token( MENOS_MENOS ); }
"if"        { return token( IF );         }
"for"       { return token( FOR );        }
"let"       { return token( LET );        }
"var"       { return token( VAR );        }
"else"      { return token( ELSE );       }
"const"     { return token( CONST );      }
"while"     { return token( WHILE );      }
"return"    { return token( RETURN );     }
"function"  { return token( FUNCTION );   }

{ASM}       { string lexema = trim( yytext + 3, " \t\n\r\f\v{}" ); 
              yylval.c = tokeniza( lexema );
              coluna += strlen( yytext ); 
              return ASM; 
            }
{BOOL}      { return token( BOOL );       }
{INT}       { return token( CINT );       }   
{DOUBLE}    { return token( CDOUBLE );    }
{STRING}    { return token( CSTRING );    }
{ID}        { return token( ID );         }
[ \n\r\t]   {                             }
.           { return token( *yytext );    }

%%

int token( int tk ) {  
  yylval.c = vector<string>{ yytext };
  coluna += strlen( yytext ); 
  
  yylval.linha = linha;
  yylval.coluna = coluna;

  return tk;
}

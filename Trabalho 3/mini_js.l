%{
int token( int tk );
%}

ID      {LETRA}({LETRA}|{DIGITO})*
INT     {DIGITO}+
LETRA   [A-Za-z_]
DIGITO  [0-9]
STRING  (\"([^\"\n]|(\\\")|\"\")+\")|(\'([^\'\n]|(\\\')|\'\')+\')
DOUBLE  {DIGITO}+"."{DIGITO}+([Ee][+\-]?{DIGITO}+)?

%%

"\t"      { coluna += 4;                }
" "       { coluna++;                   }
"\n"      { linha++; coluna = 1;        }
"{}"      { return token( OBJ );        }
"[]"      { return token( ARRAY );      }
"&&"      { return token( AND );        }
"||"      { return token( OR );         }
"<="      { return token( ME_IG );      }
">="      { return token( MA_IG );      }
"!="      { return token( DIF );        }
"=="      { return token( IGUAL );      }
"+="      { return token( MAIS_IGUAL ); }
"++"      { return token( MAIS_MAIS );  }
"if"      { return token( IF );         }
"for"     { return token( FOR );        }
"let"     { return token( LET );        }
"var"     { return token( VAR );        }
"else"    { return token( ELSE );       }
"const"   { return token( CONST );      }
"print"   { return token( PRINT );      }
"while"   { return token( WHILE );      }

{INT}     { return token( CINT );       }   
{DOUBLE}  { return token( CDOUBLE );    }
{STRING}  { return token( CSTRING );    }
{ID}      { return token( ID );         }
[ \n\r\t] {                             }
.         { return token( *yytext );    }

%%

int token( int tk ) {  
  yylval.c = vector<string>{ yytext };
  coluna += strlen( yytext ); 
  
  yylval.linha = linha;
  yylval.coluna = coluna;

  return tk;
}
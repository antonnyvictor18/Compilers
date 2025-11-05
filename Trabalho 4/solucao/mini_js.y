%{
#include <iostream>
#include <string>
#include <vector>
#include <map>

using namespace std;

int linha = 1, coluna = 0;

struct Atributos {
  vector<string> c; // Código
  vector<string> valor_default; // Valor default de parâmetro
  int contador = 0; // Contador de argumentos/parâmetros
  int profundidade_escopo = 0; // Profundidade de blocos aninhados
  int linha = 0, coluna = 0;
  
  void clear() {
    c.clear();
    valor_default.clear();
    linha = 0;
    coluna = 0;
    contador = 0;
    profundidade_escopo = 0;
  }
};

#define YYSTYPE Atributos

enum TipoDecl { Let = 1, Const, Var };

struct Simbolo {
  TipoDecl tipo;
  int linha;
  int coluna;
};

// Pilha de tabelas de símbolos para gerenciar escopos
vector< map< string, Simbolo > > pilha_ts = { map< string, Simbolo >{} }; 
vector<string> codigo_funcoes; // Código das funções (colocado no final)

extern "C" int yylex();
int yyparse();
void yyerror(const char *);

vector<string> concatena( vector<string> a, vector<string> b );
vector<string> operator+( vector<string> a, vector<string> b );
vector<string> operator+( vector<string> a, string b );
vector<string> operator+( string a, vector<string> b );
vector<string> resolve_enderecos( vector<string> entrada );
string gera_label( string prefixo );
void print( vector<string> codigo );
vector<string> declara_var( TipoDecl tipo, string nome, int linha, int coluna );
void checa_simbolo( string nome, bool modificavel );
void empilha_escopo();
void desempilha_escopo();

%}

%token IF ELSE FOR WHILE LET CONST VAR OBJ ARRAY FUNCTION ASM RETURN
%token ID CDOUBLE CSTRING CINT BOOL
%token AND OR ME_IG MA_IG DIF IGUAL
%token MAIS_IGUAL MAIS_MAIS MENOS_MENOS

%right '='
%right MAIS_IGUAL
%left OR
%left AND
%nonassoc IGUAL DIF
%nonassoc '<' '>' MA_IG ME_IG
%left '+' '-'
%left '*' '/' '%'
%right UMINUS UPLUS
%right MAIS_MAIS MENOS_MENOS
%left '[' '.' '('
%nonassoc IF
%nonassoc ELSE

%%

S : CMDs { print( resolve_enderecos( $1.c + "." + codigo_funcoes ) ); }
  ;

CMDs : CMDs CMD {$$.c = $1.c + $2.c;}
     | {$$.clear();}
     ;

CMD : CMD_LET ';'
    | CMD_VAR ';'
    | CMD_CONST ';'
    | CMD_FOR
    | CMD_IF
    | CMD_WHILE
    | CMD_FUNC
    | RETURN E ';'
      { $$.c = $2.c + "'&retorno'" + "@" + "~"; }
    | E ASM ';'
      { $$.c = $1.c + $2.c + "^"; }
    | '{' EMPILHA_TS CMDs DESEMPILHA_TS '}'
      { $$.c = vector<string>{"<{"} + $3.c + vector<string>{"}>"}; }
    | E ';'
      {$$.c = $1.c + "^";}
    | ';' 
      {$$.clear();}
    ;

EMPILHA_TS : { empilha_escopo(); }
           ;

DESEMPILHA_TS : { desempilha_escopo(); }
              ;

CMD_FUNC : FUNCTION ID 
           { declara_var( Var, $2.c[0], $2.linha, $2.coluna ); } 
           '(' EMPILHA_TS LISTA_PARAMs ')' '{' CMDs DESEMPILHA_TS '}'
           { 
             string lbl_funcao = gera_label( "func_" + $2.c[0] );
             string def_lbl_funcao = ":" + lbl_funcao;
             
             // Inicializa função no escopo atual
             $$.c = $2.c + "&" + $2.c + "{}" + "=" + "'&funcao'" +
                    lbl_funcao + "[=]" + "^";
                    
             // Adiciona o código da função no final
             codigo_funcoes = codigo_funcoes + def_lbl_funcao + $6.c + $9.c +
                              "undefined" + "@" + "'&retorno'" + "@" + "~";
           }
         ;

LISTA_PARAMs : PARAMs
             | PARAMs ','
             | { $$.clear(); }
             ;
           
PARAMs : PARAMs ',' PARAM  
       { 
         $$.c = $1.c + $3.c + "&" + $3.c + "arguments" + "@" + 
                to_string( $1.contador ) + "[@]" + "=" + "^";
         
         // Se tem valor default, adiciona verificação
         if( $3.valor_default.size() > 0 ) {
           string lbl_tem_valor = gera_label( "tem_valor" );
           string lbl_fim = gera_label( "fim_default" );
           string def_lbl_tem_valor = ":" + lbl_tem_valor;
           string def_lbl_fim = ":" + lbl_fim;
           
           $$.c = $$.c + declara_var( Var, "placeholder", 1, 1 ) + 
                  $3.c + "@" + "placeholder" + "@" + "!=" +
                  lbl_tem_valor + "?" + 
                  $3.c + $3.valor_default + "=" + "^" +
                  lbl_fim + "#" +
                  def_lbl_tem_valor + 
                  def_lbl_fim;
         }
         
         $$.contador = $1.contador + $3.contador;
       }
     | PARAM 
       { 
         $$.c = $1.c + "&" + $1.c + "arguments" + "@" + "0" + "[@]" + "=" + "^";
         
         // Se tem valor default, adiciona verificação
         if( $1.valor_default.size() > 0 ) {
           string lbl_tem_valor = gera_label( "tem_valor" );
           string lbl_fim = gera_label( "fim_default" );
           string def_lbl_tem_valor = ":" + lbl_tem_valor;
           string def_lbl_fim = ":" + lbl_fim;
           
           $$.c = $$.c + declara_var( Var, "placeholder", 1, 1 ) + 
                  $1.c + "@" + "placeholder" + "@" + "!=" +
                  lbl_tem_valor + "?" + 
                  $1.c + $1.valor_default + "=" + "^" +
                  lbl_fim + "#" +
                  def_lbl_tem_valor + 
                  def_lbl_fim;
         }
         
         $$.contador = $1.contador;
       }
     ;
     
PARAM : ID 
      { 
        $$.c = $1.c;
        $$.contador = 1;
        $$.valor_default.clear();
        declara_var( Let, $1.c[0], $1.linha, $1.coluna );
      }
      | ID '=' E
      { 
        $$.c = $1.c;
        $$.contador = 1;
        $$.valor_default = $3.c;
        declara_var( Let, $1.c[0], $1.linha, $1.coluna );
      }
      ;

CMD_FOR : FOR '(' PRIM_E ';' E ';' E ')' CMD
        { 
          string lbl_fim = gera_label( "fim_for" );
          string lbl_cond = gera_label( "cond_for" );
          string lbl_cmd = gera_label( "cmd_for" );
          string def_lbl_fim = ":" + lbl_fim;
          string def_lbl_cond = ":" + lbl_cond;
          string def_lbl_cmd = ":" + lbl_cmd;

          $$.c = $3.c + def_lbl_cond +
                 $5.c + lbl_cmd + "?" + lbl_fim + "#" +
                 def_lbl_cmd + $9.c +
                 $7.c + "^" + lbl_cond + "#" +
                 def_lbl_fim;
        }
        ;

PRIM_E : CMD_LET
       | CMD_VAR
       | CMD_CONST
       | E
         { $$.c = $1.c + "^"; }
       ;

CMD_IF : IF '(' E ')' CMD
        { 
          string lbl_true = gera_label( "if_true" );
          string lbl_fim = gera_label( "if_fim" );
          string def_lbl_true = ":" + lbl_true;
          string def_lbl_fim = ":" + lbl_fim;
          
          $$.c = $3.c +
                 lbl_true + "?" +
                 lbl_fim + "#" +
                 def_lbl_true + $5.c +
                 def_lbl_fim;
        }
       | IF '(' E ')' CMD ELSE CMD
        { 
          string lbl_true = gera_label( "if_true" );
          string lbl_fim = gera_label( "if_fim" );
          string def_lbl_true = ":" + lbl_true;
          string def_lbl_fim = ":" + lbl_fim;

          $$.c = $3.c +
                 lbl_true + "?" +
                 $7.c + lbl_fim + "#" +
                 def_lbl_true + $5.c +
                 def_lbl_fim;
        }
       ;

CMD_WHILE : WHILE '(' E ')' CMD 
          {
            string lbl_fim = gera_label( "fim_while" );
            string lbl_cond = gera_label( "cond_while" );
            string lbl_cmd = gera_label( "cmd_while" );
            string def_lbl_fim = ":" + lbl_fim;
            string def_lbl_cond = ":" + lbl_cond;
            string def_lbl_cmd = ":" + lbl_cmd;
            
            $$.c = def_lbl_cond +
                   $3.c + lbl_cmd + "?" + lbl_fim + "#" +
                   def_lbl_cmd + $5.c + lbl_cond + "#" +
                   def_lbl_fim;
          }
          ;

CMD_LET : LET LET_VARs { $$.c = $2.c; }
        ;

LET_VARs : LET_VAR ',' LET_VARs { $$.c = $1.c + $3.c; } 
         | LET_VAR
         ;

LET_VAR : ID  
          { $$.c = declara_var( Let, $1.c[0], $1.linha, $1.coluna ); }
        | ID '=' E
          { 
            $$.c = declara_var( Let, $1.c[0], $1.linha, $1.coluna ) + 
                   $1.c + $3.c + "=" + "^";
          }
        ;

CMD_VAR : VAR VAR_VARs { $$.c = $2.c; }
        ;
        
VAR_VARs : VAR_VAR ',' VAR_VARs { $$.c = $1.c + $3.c; } 
         | VAR_VAR
         ;

VAR_VAR : ID  
          { $$.c = declara_var( Var, $1.c[0], $1.linha, $1.coluna ); }
        | ID '=' E
          { 
            $$.c = declara_var( Var, $1.c[0], $1.linha, $1.coluna ) + 
                   $1.c + $3.c + "=" + "^";
          }
        ;
  
CMD_CONST: CONST CONST_VARs { $$.c = $2.c; }
         ;
  
CONST_VARs : CONST_VAR ',' CONST_VARs { $$.c = $1.c + $3.c; } 
           | CONST_VAR
           ;

CONST_VAR : ID '=' E
            { 
              $$.c = declara_var( Const, $1.c[0], $1.linha, $1.coluna ) + 
                     $1.c + $3.c + "=" + "^";
            }
          ;
     
E : LVALUE '=' E 
    { checa_simbolo( $1.c[0], true ); 
      $$.c = $1.c + $3.c + "="; }
  | LVALUE MAIS_MAIS 
    { checa_simbolo( $1.c[0], true );
      $$.c = $1.c + "@" + $1.c + $1.c + "@" + "1" + "+" + "=" + "^"; }
  | LVALUE MENOS_MENOS 
    { checa_simbolo( $1.c[0], true );
      $$.c = $1.c + "@" + $1.c + $1.c + "@" + "1" + "-" + "=" + "^"; }
  | LVALUEPROP MAIS_MAIS
    { $$.c = $1.c + "[@]" + $1.c + $1.c + "[@]" + "1" + "+" + "[=]" + "^"; }
  | LVALUEPROP MENOS_MENOS
    { $$.c = $1.c + "[@]" + $1.c + $1.c + "[@]" + "1" + "-" + "[=]" + "^"; }
  | MAIS_MAIS LVALUE
    { checa_simbolo( $2.c[0], true );
      $$.c = $2.c + $2.c + "@" + "1" + "+" + "=" + "@"; }
  | MENOS_MENOS LVALUE
    { checa_simbolo( $2.c[0], true );
      $$.c = $2.c + $2.c + "@" + "1" + "-" + "=" + "@"; }
  | MAIS_MAIS LVALUEPROP
    { $$.c = $2.c + $2.c + "[@]" + "1" + "+" + "[=]" + "[@]"; }
  | MENOS_MENOS LVALUEPROP
    { $$.c = $2.c + $2.c + "[@]" + "1" + "-" + "[=]" + "[@]"; }
  | LVALUE MAIS_IGUAL E     
    { checa_simbolo( $1.c[0], true ); 
      $$.c = $1.c + $1.c + "@" + $3.c + "+" + "="; }
  | LVALUEPROP '=' E 	
    { $$.c = $1.c + $3.c + "[=]"; }
  | LVALUEPROP MAIS_IGUAL E
    { $$.c = $1.c + $1.c + "[@]" + $3.c + "+" + "[=]"; }
  | E ME_IG E   
    { $$.c = $1.c + $3.c + "<="; }
  | E MA_IG E   
    { $$.c = $1.c + $3.c + ">="; }
  | E IGUAL E   
    { $$.c = $1.c + $3.c + "=="; }
  | E DIF E     
    { $$.c = $1.c + $3.c + "!="; }
  | E '<' E
    { $$.c = $1.c + $3.c + "<"; }
  | E '>' E
    { $$.c = $1.c + $3.c + ">"; }
  | E '+' E
    { $$.c = $1.c + $3.c + "+"; }
  | E '-' E
    { $$.c = $1.c + $3.c + "-"; }
  | E '*' E
    { $$.c = $1.c + $3.c + "*"; }
  | E '/' E
    { $$.c = $1.c + $3.c + "/"; }
  | E '%' E
    { $$.c = $1.c + $3.c + "%"; }
  | '-' E %prec UMINUS
    { $$.c = "0" + $2.c + $1.c; }
  | '+' E %prec UPLUS
    { $$.c = $2.c; }
  | E '(' LISTA_ARGs ')'
    { $$.c = $3.c + to_string( $3.contador ) + $1.c + "$"; }
  | '[' ']'             
    { $$.c = vector<string>{"[]"}; }
  | '{' '}'
    { $$.c = vector<string>{"{}"}; }
  | ARRAY            
    { $$.c = vector<string>{"[]"}; }
  | OBJ
    { $$.c = vector<string>{"{}"}; }
  | CDOUBLE
  | CINT
  | CSTRING
  | BOOL
  | LVALUE 
    { checa_simbolo( $1.c[0], false ); 
      $$.c = $1.c + "@"; }
  | LVALUEPROP
    { $$.c = $1.c + "[@]"; }
  | '(' E ')' 
    { $$.c = $2.c; }
  ;

LISTA_ARGs : ARGs
           | ARGs ','
           | { $$.clear(); }
           ;
           
ARGs : ARGs ',' E
       { $$.c = $1.c + $3.c;
         $$.contador = $1.contador + 1; }
     | E
       { $$.c = $1.c;
         $$.contador = 1; }
     ;

LVALUE : ID 
       ;
       
LVALUEPROP : LVALUE '[' E ']' { $$.c = $1.c + "@" + $3.c; }
           | LVALUE '.' ID    { $$.c = $1.c + "@" + $3.c; }
           | '(' E ')' '[' E ']' { $$.c = $2.c + $5.c; }
           | '(' E ')' '.' ID { $$.c = $2.c + $5.c; }
           | LVALUEPROP '[' E ']' { $$.c = $1.c + "[@]" + $3.c; }
           | LVALUEPROP '.' ID    { $$.c = $1.c + "[@]" + $3.c; }
           ;

%%

#include "lex.yy.c"

vector<string> concatena( vector<string> a, vector<string> b ) {
  a.insert( a.end(), b.begin(), b.end() );
  return a;
}

vector<string> operator+( vector<string> a, vector<string> b ) {
  return concatena( a, b );
}

vector<string> operator+( vector<string> a, string b ) {
  a.push_back( b );
  return a;
}

vector<string> operator+( string a, vector<string> b ) {
  return vector<string>{ a } + b;
}

vector<string> resolve_enderecos( vector<string> entrada ) {
  map<string,int> label;
  vector<string> saida;
  
  for( int i = 0; i < entrada.size(); i++ )
    if( entrada[i][0] == ':' )
      label[entrada[i].substr(1)] = saida.size();
    else
      saida.push_back( entrada[i] );

  for( int i = 0; i < saida.size(); i++ )
    if( label.count( saida[i] ) > 0 )
      saida[i] = to_string( label[saida[i]] );

  return saida;
}

string gera_label( string prefixo ) {
  static int n = 0;
  return prefixo + "_" + to_string( ++n ) + ":";
}

void print( vector<string> codigo ) {
  for( string s : codigo )
    cout << s << " ";
  cout << endl;
}

void empilha_escopo() {
  pilha_ts.push_back( map< string, Simbolo >{} );
}

void desempilha_escopo() {
  pilha_ts.pop_back();
}

vector<string> declara_var( TipoDecl tipo, string nome, int linha, int coluna ) {
  auto& escopo_atual = pilha_ts.back();
  
  if( escopo_atual.count( nome ) == 0 ) {
    escopo_atual[nome] = Simbolo{ tipo, linha, coluna };
    return vector<string>{ nome, "&" };
  }
  else if( tipo == Var && escopo_atual[nome].tipo == Var ) {
    escopo_atual[nome] = Simbolo{ tipo, linha, coluna };
    return vector<string>{};
  } 
  else {
    cerr << "Erro: a variável '" << nome << "' já foi declarada na linha " 
         << escopo_atual[nome].linha << "." << endl;
    exit( 1 );
  }
}

void checa_simbolo( string nome, bool modificavel ) {
  for( int i = pilha_ts.size() - 1; i >= 0; i-- ) {
    auto& escopo = pilha_ts[i];
    
    if( escopo.count( nome ) > 0 ) {
      if( modificavel && escopo[nome].tipo == Const ) {
        cerr << "Variavel '" << nome << "' não pode ser modificada." << endl;
        exit( 1 );
      }
      return;
    }
  }
}

void yyerror( const char* st ) {
  puts( st );
  printf( "Proximo a: %s\n", yytext );
  exit( 1 );
}

int main( int argc, char* argv[] ) {
  yyparse();
  return 0;
}

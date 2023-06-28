%{
#include <ctype.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>
#include<string.h>

#define WIDTH 60
#define HEIGHT 20
#define X WIDTH/2
#define Y HEIGHT/2
#define XMAX WIDTH-X-1
#define XMIN -(WIDTH-X)
#define YMAX HEIGHT-Y
#define YMIN -(HEIGHT-Y)+1

#define YYSTYPE double /* double type for YACC stack */


//implementando tabla de simbolos
typedef struct{
	char name[64];
	int token;
	double value;
}SymbolEntry;

SymbolEntry symbolTable[100];
int numEntries=0;

void imprimeTablaSim();
//fin de variables para tabla de simbolos


//implementando tabla de codigos

typedef struct{int op;int a1;int  a2;int a3;}tipoCodigo;
int cx=-1;
tipoCodigo TCodigo[100];
void imprimeTablaCod();
int nVarTemp=0;
int GenVarTemp();
//fin


int *ptr1,*ptr2;
int fin=0;
char grid[HEIGHT][WIDTH];

void graphic(char *m,float min, float max);
int plot(int x, int y);
void init_grid(void);
void show_grid(void);

//help
void help(void);

int vec1[25];
int vec2[25];
int m=0,r=0,n=0,p=0;

//void printOpe(&matrixA,matrixB);
char lex[255];
void yyerror(char *);
int yylex();



int factorial(int num){
	int f=1;
	for(int i=1;i<=num;i++){
		f=i*f;
	}
	return f;
}

int sumatoria(int min,int max, int num){
//ax+b
	int sum=0;
	for(int i=min;i<=max;i++){
		sum=sum+num;
	}
	return sum;
}

void matrix(int n){
	p=p+1;
	
	if(fin<1) {
		
		vec1[m]=n;
		m=m+1;
	}
	else{
	
	vec2[r]=n;
	r=r+1;
	}
}

void addMatrix(void){
	int f,c;
	f=n/2;
	c=(int)p/n;
	int res[f][c];
	printf("fila f: %d\n",f);
	printf("columna c: %d\n",c);
	
	for(int i=0;i<f;i++){
		for (int j=0;j<c;j++){
			res[i][j]=vec1[i*c+j]+vec2[i*c+j];
		}
	}	
		
	printf("La suma es: \n");
	for(int i=0;i<f;i++){
		for (int j=0;j<c;j++){
			printf("%d ",res[i][j]);
		}printf("\n");
	}
	printf("\n");
	
}

void generaCodigo(int op,int a1,int a2,int a3){
	cx++;	
	TCodigo[cx].op=op;
	TCodigo[cx].a1=a1;
	TCodigo[cx].a2=a2;
	TCodigo[cx].a3=a3;
}


void addtoSymbolTable(char* name,int token, double value){
	SymbolEntry entry;
	strcpy(entry.name,name);
	entry.token=token;
	entry.value=value;
	symbolTable[numEntries++]=entry;
}

int lookupSymbol(char* name,int token) {
    for (int i = 0; i < numEntries; i++) {
        if (strcmp(symbolTable[i].name, name) == 0) {
            return i;
        }
    }
	addtoSymbolTable(name,token,0);
    return numEntries-1;  // Entry not found, return default value
}

int GenVarTemp();

void imprimeTablaSim(){
	int i;
	for (i=0;i<numEntries;i++){
		printf("%d nombre=%s  token=%d  value=%lf\n",i,symbolTable[i].name,symbolTable[i].token,symbolTable[i].value);
	}
}

void imprimeTablaCod(){
	int i;
	for ( i=0;i<=cx;i++){
		printf("%d  a1=%d a2=%d a3=%d\n",TCodigo[i].op,TCodigo[i].a1,TCodigo[i].a2,TCodigo[i].a3);
	}
}

%}

%token NUMBER SUMANDO RESTANDO MULTIPLICANDO DIVIDIENDO MAS MENOS MUL DIV SIN COS TAN LOG NLOG SQRT POW SINH COSH TANH ASIN ACOS ATAN ABS SUM HELP ADD MULT MATRIX

%%
prog: expr '\n'   prog { 	printf("tabla de simbolos\n");
				imprimeTablaSim();
				printf("tabla de codigos\n");
				imprimeTablaCod();

				printf("Resultado: %g\n",$1);  };
prog:  ;





expr: expr MAS term  	{ $$ = $1 + $3; int i=GenVarTemp(); generaCodigo(SUMANDO,i,$1,$3);}
	| expr MENOS  term	{ $$ = $1 - $3; int i=GenVarTemp(); generaCodigo(RESTANDO,i,$1,$3);}
	| term
	|op
	|graphic
	|h
	
	;
h: HELP {help();}
 ;
term: term MUL mm {$$=$1 * $3;int i=GenVarTemp(); generaCodigo(MULTIPLICANDO,i,$1,$3);}
	| term DIV mm {$$=$1 / $3;int i=GenVarTemp(); generaCodigo(DIVIDIENDO,i,$1,$3);}
	| mm
	;

mm: '(' expr ')'	{$$=$2;}
  | MENOS fun {$$=-1*$2;}
  | fun
  ;
fun: SIN '(' expr ')' {$$=sin($3);}
   | COS '(' expr ')' {$$=cos($3);}
   | TAN '(' expr ')' {$$=tan($3);}
   | LOG '(' expr ')' {$$=log10($3);}
   | NLOG '(' expr ')' {$$=log($3);}
   | SQRT '(' expr ')' {$$=sqrt($3);}
   | POW '(' expr ',' expr ')' {$$=pow($3,$5);}
   | SINH '(' expr ')' {$$=sinh($3);}
   | COSH '(' expr ')' {$$=cosh($3);}
   | TANH '(' expr ')' {$$=tanh($3);}
   | ASIN '(' expr ')' {$$=asin($3);}
   | ACOS '(' expr ')' {$$=acos($3);}
   | ATAN '(' expr ')' {$$=atan($3);}
   | ABS '(' expr ')' {$$=abs($3);}
   | SUM '(' expr ',' expr ')' NUMBER {$$=sumatoria($3,$5,$7);}
   | NUMBER '!' {$$=factorial($1);}
   //| '(' expr ')'	{$$=$2;}
   | NUMBER {$$=$1; addtoSymbolTable(lex,NUMBER,$1);} 
   ; 
graphic: SIN '(' expr ',' expr ')' {graphic("sin",$3,$5);}
     | COS '(' expr ',' expr ')' {graphic("cos",$3,$5);}
     | TAN '(' expr ',' expr ')' {graphic("tan",$3,$5);}
     | LOG '(' expr ',' expr ')' {graphic("log",$3,$5);}
     ;

op: M ADD M {addMatrix();}
  //| M MULT  M {mulMatrix();}
  //| M '-' M
  | M

  ;
M: '[' matrix_list ']' {fin=fin+1;}
    ;

matrix_list: matrix //{ n = n+1; }
            | matrix_list ',' matrix //{ n=n+1; }
            ;

matrix: '[' row_list ']' { n=n+1;}
      ;

row_list: row //{$$=$1;}
        | row_list ',' row //{pi($1,$3);}
        ;

row:  NUMBER { $$=$1; matrix($1); }
   ;
%%


int GenVarTemp(){
	char t[60];
	sprintf(t,"_T%d",nVarTemp++);
	int res=lookupSymbol(t,NUMBER);
	return res;
}

void yyerror(char *mgs){
	printf("error: %s",mgs);
}

int yylex(void)
{ double t;
	int c;
	while ((c = getchar()) == ' ');
	if (c == '.' || isdigit(c)) {
		ungetc(c, stdin);
		scanf("%lf", &t); yylval=t;// pasando valor a la pila
		return NUMBER;
	}
	if(c=='+') return MAS;
	if (c=='-') return MENOS;
	if (c=='*') return MUL;
	if (c=='/') return DIV;
	if (isalpha(c)) {
		int i=0;
	  	do{
	  		lex[i++]=c;
	  		c=getchar();
	  		
	  	}while(isalpha(c));
	  	
	  	ungetc(c,stdin);
	  	lex[i]=0;
		int num_ele=sizeof(lex)/sizeof(lex[0]);
		
		if(strcmp(lex,"sin")==0) return SIN;
		if(strcmp(lex,"cos")==0) return COS;
		if(strcmp(lex,"tan")==0) return TAN;
		if(strcmp(lex,"log")==0) return LOG;
		if(strcmp(lex,"nlog")==0) return NLOG;
		if(strcmp(lex,"pow")==0) return POW;
		if(strcmp(lex,"sqrt")==0) return SQRT;
		if(strcmp(lex,"sinh")==0) return SINH;
		if(strcmp(lex,"cosh")==0) return COSH;
		if(strcmp(lex,"tanh")==0) return TANH;
		if(strcmp(lex,"asin")==0) return ASIN;
		if(strcmp(lex,"acos")==0) return ACOS;
		if(strcmp(lex,"atan")==0) return ATAN;
		if(strcmp(lex,"abs")==0) return ABS;
		if(strcmp(lex,"sum")==0) return SUM;
		if(strcmp(lex,"help")==0) return HELP;
		if(strcmp(lex,"matrices")==0) return MATRIX;
		if(strcmp(lex,"add")==0) return ADD;
		if(strcmp(lex,"mult")==0) return MULT;
		
		
	}
	return c;
}
int main(void)
{
	return yyparse();
	
}

void graphic(char *m,float min, float max){
	float x,y;
    	init_grid();
    	//deafult min =-3.14159 y max= 3.14159
    	for(x=min;x<=max;x+=0.1)
    	{	if(strcmp(m,"sin")==0)
        		y = sin(x);
        	if(strcmp(m,"cos")==0)
        		y = cos(x);
        	if(strcmp(m,"tan")==0)
        		y = tan(x);
        	if(strcmp(m,"log")==0)
        		y = log10(x);
        	plot(rintf(x*10),rintf(y*8));
    	}
    	show_grid();

}

int plot(int x, int y)
{
    if( x > XMAX || x < XMIN || y > YMAX || y < YMIN )
        return(-1);

    grid[Y-y][X+x] = '*';
    return(1);
}

/*Se inicializa GRID */
void init_grid(void)
{
    int x,y;

    for(y=0;y<HEIGHT;y++)
        for(x=0;x<WIDTH;x++)
            grid[y][x] = ' ';
    /* draw the axis */
    for(y=0;y<HEIGHT;y++)
        grid[y][X] = '|';
    for(x=0;x<WIDTH;x++)
        grid[Y][x] = '-';
    grid[Y][X] = '+';
}

/* Se muestra GRID */
void show_grid(void)
{
    int x,y;

    for(y=0;y<HEIGHT;y++)
    {
        for(x=0;x<WIDTH;x++)
            putchar(grid[y][x]);
        putchar('\n');
    }
}

void help(void){
	printf("Usted puede usar las siguientes operaciones: \n");
	printf("N! --> FACTORIAL, escriba un número entero seguido del simbolo ! \n");
	printf("funciones \n");
	printf("sin(argument) --> función seno(), escriba la funnión sin y entre parentesis le puede dar como argumento operaciones matematicas, funciones y números reales \n");
}

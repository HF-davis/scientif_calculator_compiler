%{
#include<stdio.h>
#include<stdlib.h>
#include<string.h>
#include<ctype.h>

char lexema[60];
void yyerror(char *);
int yylex();
typedef struct{
	char nombre[60];
	double valor;
	int token;
}tipoTS;
tipoTS TablaSim[100];
int nSim=0;//fila de la tabla de símbolo
int count=0,var1=-1,var2;
typedef struct{
	int op;
	int a1;
	int a2;
	int a3;
}tipoCodigo;
tipoCodigo TCodigo[100];
int cx=-1; //fila de la tabla de tabla de código
void generaCodigo(int,int,int,int);//llena la tabla de código
int localizaSimb(char *,int);//llena la tabla de símbolos
void imprimeTablaSim();
void imprimeTablaCod();
int GenVarTemp();//genera variables temporales
int nVarTemp=0;
char id=' ';
int idx=0,che=0;
typedef struct{
	char *name;
	int fun;
} function;
function fun_[100];
int last,neg=0,pos=0;
void interpretaCodigo();//recorre la tabla de código para actualizar la tabla de símbolos
int esPalabraReservada(char lexema[]);
%}

%token PROGRAMA ID INICIO FIN NUM ASIGNAR SUMAR SI SINO ENTONCES MAYOR SALTARF IGUAL MIENTRAS HACER FINMIENTRAS DEF FUNCION CHECK_F
/*

Program MiProg;
Begin
	x:=5;
	y:=6;
	if y>x then
		Begin
			a:=2;
			b:=3;
		End
	z:=6;
End.
*/
%%
S: PROGRAMA ID ';' INICIO listaInstr FIN '.';

listaInstr: instr sin listaInstr|mien | ;

mien: MIENTRAS  cond {generaCodigo(SALTARF,$2,'?',2),$$=cx;} HACER bloque{TCodigo[$3].a2=cx+1;} FINMIENTRAS;

instr: SI cond {generaCodigo(SALTARF,$2,'?','-');pos=pos+1;$$=cx;} ENTONCES bloque{TCodigo[$3].a2=cx+1;};

sin:SINO {generaCodigo(SALTARF,last,'?',1);count=count+1;$$=cx;} bloque {TCodigo[$2].a2=cx+1;}
   | 
   ;
bloque: INICIO listaInstr FIN|instr;

instr: ID {$$=localizaSimb(lexema,ID);}':''=' expr{generaCodigo(ASIGNAR,$2,$5,'-');} ';'
     |	fun
     | ID {int i=GenVarTemp();generaCodigo(CHECK_F,i,'?','-');} '(' ')' 
     ;
fun: DEF ID{fun_[idx].name=lexema; } '('  ')' {int i=GenVarTemp();generaCodigo(FUNCION,i,'?', '-');fun_[idx].fun=cx;idx=idx+1;printf("cx_fun=%d",cx);$$=cx;}':' bloque{TCodigo[$6].a2=cx+1;}
   ;

 
cond: expr'>'expr  {int i=GenVarTemp(); generaCodigo(MAYOR,i,$1,$3);last=i;$$=i;}
    |expr '=' expr {int i=GenVarTemp(); generaCodigo(IGUAL,i,$1,$3);last=i;$$=i;}
    ; 
expr:expr '+' term {int i=GenVarTemp(); generaCodigo(SUMAR,i,$1,$3);$$=i;};

expr:term;

term:NUM {$$=localizaSimb(lexema,NUM);}|ID{$$=localizaSimb(lexema,ID);};
%%

int GenVarTemp(){
	char t[20];
	sprintf(t,"_T%d",nVarTemp++);
	return localizaSimb(t,ID);
}

void generaCodigo(int op,int a1,int a2, int a3){
	cx++;
	TCodigo[cx].op=op;
	TCodigo[cx].a1=a1;
	TCodigo[cx].a2=a2;
	TCodigo[cx].a3=a3;
}

int localizaSimb(char *nom, int tok){
	int i;
	for(i=0;i<nSim;i++){
		if(!strcasecmp(TablaSim[i].nombre,nom))
			return i;	
	}
	strcpy(TablaSim[nSim].nombre,nom);
	TablaSim[nSim].token=tok;
	if(tok=ID) TablaSim[nSim].valor=0.0;
	if(tok=NUM) sscanf(nom,"%lf",&TablaSim[nSim].valor);
	nSim++;
	return nSim-1;
}

void imprimeTablaSim(){
	int i;
	for(i=0;i<nSim;i++)
	printf("%d nombre=%s tok=%d valor=%lf\n",i,TablaSim[i].nombre,TablaSim[i].token, TablaSim[i].valor);
}
void imprimeTablaCod(){
	int i;
	for(i=0;i<=cx;i++)
	printf("%d op=%d a1=%d a2=%d a3=%d\n",i,TCodigo[i].op, TCodigo[i].a1,TCodigo[i].a2, TCodigo[i].a3);
}

void interpretaCodigo(){
	int i,a1,a2,a3,op;
	for(i=0;i<=cx;i++){
		op=TCodigo[i].op;
		a1=TCodigo[i].a1;
		a2=TCodigo[i].a2;
		a3=TCodigo[i].a3;
		if(op==ASIGNAR){
			TablaSim[a1].valor=TablaSim[a2].valor;
			printf("\nval_after_assig=%fl\n",TablaSim[a1].valor);}
		if(op==SUMAR)
			TablaSim[a1].valor=TablaSim[a2].valor+TablaSim[a3].valor;
			
		if(op==MAYOR)
			if(TablaSim[a2].valor>TablaSim[a3].valor)
				TablaSim[a1].valor=1;
			else 
				TablaSim[a1].valor=0;
		if(op==IGUAL)
			if(TablaSim[a2].valor==TablaSim[a3].valor)
				TablaSim[a1].valor=1;
			else 
				TablaSim[a1].valor=0;
		
		if(op==FUNCION){
			i=a2-1;
		}			
		if(op==CHECK_F){
			che=che+1;
			if (che==1) {i=fun_[0].fun;printf("\nche=%d",che);}
		}		
		if(op==SALTARF){
			//neg, sirve para contar SALTARF que se dan
			neg=neg+1;
			printf("\na3=%d\n",a3);
			if(TablaSim[a1].valor==0){
				
				if(a3==2) i=a2-1; //para saltar while
				printf("\nval_a1=0 y a2=%d neg=%d\n",a2,neg);
				if(pos>0 && a3!=1) i=a2-1; //cuando igual 
			}else{
				
				
				if(a3==2){var1=a2-1;var2=i-1;id='w';} //para tener en cuenta while
				printf("\n count=%d a1=%d a2=%d neg=%d\n",count,a1,a2,neg);
				if(a3==1 && neg>=2) {i=a2-1;}
					
					}
					
				
				}
				
				if(i==var1 && id=='w'){i=var2-1;id=' ';}//saltar a la condicion while
	}
}
void yyerror(char *msg){
	printf("Error: %s\n",msg);
}

int esPalabraReservada(char lexema[]){
	if(strcasecmp(lexema,"Program")==0) return PROGRAMA;
	if(strcasecmp(lexema,"Begin")==0) return INICIO;
	if(strcasecmp(lexema,"End")==0) return FIN;
	if(strcasecmp(lexema,"if")==0) return SI;
	if(strcasecmp(lexema,"then")==0) return ENTONCES;
	if(strcasecmp(lexema,"else")==0) return SINO;
	if(strcasecmp(lexema,"while")==0) return MIENTRAS;
	if(strcasecmp(lexema,"do")==0) return HACER;
	if(strcasecmp(lexema,"EndW")==0) return FINMIENTRAS;
	if(strcasecmp(lexema,"def")==0) return DEF;
	return ID;
}
int yylex(){
	char c;
	int i;
	while(1){
		c=getchar();
		if(c==' ') continue;
		if(c=='\t')continue;
		if(c=='\n')continue;
		if(isdigit(c)){
			i=0;
			do{
				lexema[i++]=c;
				c=getchar();
			}while(isdigit(c));
			ungetc(c,stdin);
			lexema[i]='\0';
			return NUM;
		}
		if(isalpha(c)){
			i=0;
			do{
				lexema[i++]=c;
				c=getchar();
			}while(isalnum(c));
			ungetc(c,stdin);
			lexema[i]='\0';
			return esPalabraReservada(lexema);
		}
		return c;

	}

}
int main(){
	if(!yyparse()) printf("Cadena válida\n");
	else printf("Cadena inválida\n");
	printf("Tabla de símbolos\n");
	imprimeTablaSim();
	printf("Tabla de códigos\n");
	imprimeTablaCod();
	printf("Interpreta código\n");
	interpretaCodigo();
	imprimeTablaSim();
}

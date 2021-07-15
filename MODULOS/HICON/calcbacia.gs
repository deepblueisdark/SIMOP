*--------------------------------------------------------------
* CALCBACIA VERSAO 1.0   ->   VEIO DO SCRIPT SIMOP ATÉ 2.0  
* 
* Calcula a soma e média de uma quantidade dentro de um contorno de uma bacia ou região qualquer. 
*
* INPUT:  arquivos criado pelo processo ADDBACIA e um arquivo de dados 
* 
*--------------------------------------------------------------



'quit'


*
* calcbacia ( variavel a ser calculada, tempo inicial , numero de tempos a processar , prefixo do arquivo de saida) 
*
function calcbacia( vargrads, t0,  numtempos , prefixo)  

* 
* variaveis globais de controle de fluxo
*
_id=0
_status=0
_args=""

*
* loop principal 
*
while ( 0=0 )      
*
* abre o arquivo bacias e pega um registro
*
id=getfile(0)

*
*==================================================
*
*
* se tiver </START/> inicia o processo 
*
*say _args
if (_args ="</BACIA/>") 
*
* pega novo registro 
*
id=getfile(1)

*
* pega nome da bacia e quantidade de pontos (lat,lon)
*
bacia=subwrd(_args,2)
numlin=subwrd(_args,4)
debug=subwrd(_args,6) 

if (debug =1) 
dbg="DEBUG ATIVADO"
endif
say "Processando:"bacia" com "numlin" coordenadas "dbg 
*
* inicializa variveis indexadas
*
n=1
t=t0
while (t<=numtempos)
valor.t=0
media.t=0
t=t+1
endwhile

*
* processa cada coordenada do arquivo de bacias
*
while ( n <= numlin)
*
* pega novo registro 
*
id=getfile(2)

*
* trata lat e lon 
*
lonxx=subwrd(_args,1)
lonx=lonxx
latx=subwrd(_args,2)
'set lon 'lonx
'set lat 'latx
*
* varre no tempo 
* e armazena o valor em variavel indexada
* e acumula no tempo para cada ponto
*  
t=t0
while ( t<=numtempos)
'set t 't
'd 'vargrads''
valor=subwrd(result,4)
say valor' ---'result' 'lonx' 'latx' 't
if (valor < 0.2 )
valor = 0.0
endif 
valor.t=valor.t+valor
if ( debug = 1)
xi=write("debug.prn",lonx' 'latx' 't' 'valor' 'valor.t)
endif

t=t+1
endwhile      
*
* próxima coordenada
*
n=n+1
endwhile
*
*
* ao fim calcula as médias para cada tempo

t=t0
while (t<=numtempos)
media.t=valor.t/numlin
*say "--->"media.t"===+"valor.t
t=t+1
endwhile
*
* grava os dados em um arquivo 
*

t=t0
while(t<=numtempos)
'set t 't
'q time'
datap=subwrd(result,3)
ano=substr(datap,9,4)
mes=substr(datap,6,3) 
dia=substr(datap,4,2)
hora=substr(datap,1,2)
***#### adicionado por regis em 31072017
if (mes = "JAN" ) ; mesx=1; endif 
if (mes = "FEB" ) ; mesx=2; endif 
if (mes = "MAR" ) ; mesx=3; endif 
if (mes = "APR" ) ; mesx=4; endif 
if (mes = "MAY" ) ; mesx=5; endif 
if (mes = "JUN" ) ; mesx=6; endif 
if (mes = "JUL" ) ; mesx=7; endif 
if (mes = "AUG" ) ; mesx=8; endif 
if (mes = "SEP" ) ; mesx=9; endif 
if (mes = "OCT" ) ; mesx=10; endif 
if (mes = "NOV" ) ; mesx=11; endif 
if (mes = "DEC" ) ; mesx=12; endif 

pi=write(prefixo"_"bacia".prn",ano' 'mesx' 'dia' 'hora' 'media.t)
t=t+1

endwhile



endif       
*
*==================================================
*
*say _args

if (_args ="</END/>")      
say "Fim da operacao"
close ("bacias.dat")
return
endif



endwhile 
close ("bacias.dat")
return 



function getfile()
_id=read("bacias.dat")
_status=sublin(_id,1)   
_args=sublin(_id,2)

if (_status < 0 )
'quit'
endif 
return 


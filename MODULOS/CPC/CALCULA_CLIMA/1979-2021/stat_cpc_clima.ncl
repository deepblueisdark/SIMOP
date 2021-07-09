load "$NCARG_ROOT/lib/ncarg/nclscripts/contrib/cd_inv_string.ncl"
  
;




begin


	config=True
	config@input_stat="climacpc_chuva_SAE.csv"
	config@output_stat="climacpc_chuva_stat_SAE"
	
	if(.not.isdefined("ano_inicial")) 
		ano_inicial=1979
	end if 
	if(.not.isdefined("ano_final")) 
		ano_final=2021
	end if 
	
	
	print(" Calculando a partir do ano "+ano_inicial+" ate o ano de "+ano_final)

	
	units="days since  "+ano_inicial+"-01-01 00:00:00"
    print(units)

 
	
	if(isdefined("num_bacias") )
		print(" Trabalhando com:"+num_bacias+" bacias") 
	else
		print(" Erro. Numero de bacias não definido")
		exit
	end if 
	;
    ; le arquivo de pre-estatitisca 
	;
	nrow = numAsciiRow(	config@input_stat)
	ncol = numAsciiCol(	config@input_stat)+1
	print("Arquivo com "+nrow+" linhas e "+ncol+" colunas")
	base = readAsciiTable(	config@input_stat, ncol, "float",0)
	;
	; cria as variaveis statisticas
	;
    soma=new((/5,nrow+1,num_bacias/),"float")
	stats=new((/num_bacias,((ano_final+1)-ano_inicial),12,31/),"float",0)
	stats=0.0
	;
	; tempos
	;
	id_tempos=tointeger(cd_inv_calendar(tointeger(base(:,0)),tointeger(base(:,1)),tointeger(base(:,2)),tointeger(base(:,0))*0,tointeger(base(:,0))*0,tointeger(base(:,0))*0,units,0))
	id_tempos@units=units
	itime_max=tointeger(max(id_tempos))
	itime_min=tointeger(min(id_tempos))
	temp=new((/nrow+1/),"float")
	do i=0,nrow-1
	    temp(i)=i
	end do	
	temp@units=units
	tempos=tointeger(cd_calendar(temp,0))
	;print(tempos)

	;
	; procesos de chuva acumulada futura e passada
	;
	soma=-1
	do j=0,num_bacias-1
		;
		; soma 15 dias futura
		;
		;print(" soma futura 15 dias")
		do i=0,nrow-16
				soma(0,i,j)=sum(base(i:i+15,7+j))
		end do 
		
		;
		; soma 7 dias futura
		;
		;print(" soma futura 7 dias")
		do i=0,nrow-8	
				soma(1,i,j)=sum(base(i:i+7,7+j)) 
		end do 
	
		;
		; soma 15 dias passada
		;
		;print(" soma passado 15 dias")
		do i=15,nrow-1	

				soma(2,i,j)=sum(base(i-15:i,7+j)) 
		end do 
		;print(" soma passado 15 dias")
		;
		; soma 7 dias passada
		;
		do i=7,nrow-1	
			soma(3,i,j)=sum(base(i-7:i,7+j)) 
		end do 
		;
		; otimizando para gerar estatisticas
		;
		do i=0,nrow-1
			;print(tempos(i,0)+" "+tempos(i,1)+" "+tempos(i,2))
			iano=tempos(i,0)-ano_inicial
			imes=tempos(i,1)-1
			stats(j,tempos(i,0)-ano_inicial,tempos(i,1)-1,tempos(i,2)-1)=base(i,7+j)
		end do 
		
	end do

	print("calculando stat do emes")
		num_rec=(((ano_final+1)-ano_inicial))*12
		statmes=new((/num_bacias,12,30/),"float") 
		statano=new((/num_bacias,((ano_final+1)-ano_inicial),30/),"float") 
		statall=new((/num_bacias,num_rec	,30/),"float") 
		tempos_statall=new((/num_rec/),"string") 
		
	
		
		do j=0,num_bacias-1
			do mes=0,11
				statmes(j,mes,:)=stat_dispersion(stats(j,:,mes,:),False)
			end do

			do a=ano_inicial,ano_final
				statano(j,a-ano_inicial,:)=stat_dispersion(stats(j,a-ano_inicial,:,:),False) 
			end do
			

		end do	
		
		
					print(" stst ano e  mes")
		
		
		do j=0,num_bacias-1
		k=-1
		
			do mes=0,11
				do a=ano_inicial,ano_final
					k=k+1
					;print(k+" "+j+" "+a+" "+mes)
					statall(j,k,:)=stat_dispersion(stats(j,a-ano_inicial,mes,:),False)
					if (j .eq. 0) 
					tempos_statall(k)=sprinti("%04d ",a)+sprinti("%02d ",mes+1)		
					end if 
				end do
			end do		
		end do	
		statano!0="bacia"
		statano!1="ano"
		statano!2="valor"
		
		statmes!0="bacia"
		statmes!1="mes"
		statmes!2="valor"		
statall!0="bacia"
		statall!1="time"
		statall!2="valor"		
;#
;#
;#
	statLabel = (/ "    mean", "  stddev", "     min" \
               , "  lowDec", "  LowOct", "  LowSex" \
               , "LowQuart", "  LowTri" \
               , "  Median" \
               , "   HiTri", " HiQuart","   HiSex","   HiOct", "   HiDec" \
               , "     Max", "   Range","  Disper","     RMS" \
               , "    nTot", "    nUse","    nMsg","    %Msg" /)
	asciiwrite(".stat_headers.dat",statLabel)
	;
	;
	;  grava em opt@fout a saida dos dados
	;
	;
	;  inicialziacao dos arquivos temporarios e finais
	;
print(statmes(:,0,0))
	opt=True
	opt@fout="temp_stat_cpc.csv"
	if (fileexists("out.csv")) then
		system("rm out.csv")
		title="estatisticas mensais clima"
		asciiwrite("out.csv",title)
	else
		title="estatisticas mensais clima"
		asciiwrite("out.csv",title)
	end if
	if (fileexists("temp_stat_cpc.csv")) then
		system("rm temp_stat_cpc.csv")
	end if 
	;
	;   cria a tabela e depois grava em arquivo
	;
    fmt=sprinti("%d",num_bacias)+"f10.4"
	
	do mes=0,11
		title="Mes= "+sprinti("%02d",mes+1)
		opt@title=title
		b:=statmes(:,mes,:)
		c:=b(valor|:,bacia|:)
		c@_FillValue=-1
		write_matrix(c,fmt,opt)
		system("cat temp_stat_cpc.csv >> out.csv")
	end do
	system("mv out.csv "+config@output_stat+"_mensal.csv") 
	system("rm temp_stat_cpc.csv")		
	
	
	if (fileexists("out.csv")) then
		system("rm out.csv")
		title="estatisticas mensais clima"
		asciiwrite("out.csv",title)
	else
		title="estatisticas mensais clima"
		asciiwrite("out.csv",title)
	end if
	if (fileexists("temp_stat_cpc.csv")) then
		system("rm temp_stat_cpc.csv")
	end if 
	do ano=ano_inicial,ano_final
		title="ANO= "+sprinti("%04d",ano+1)
		opt@title=title
		b:=statano(:,ano-ano_inicial,:)
		c:=b(valor|:,bacia|:)
		c@_FillValue=-1
		write_matrix(c,fmt,opt)
		system("cat temp_stat_cpc.csv >> out.csv")
	end do
	system("mv out.csv "+config@output_stat+"_anual.csv") 
	system("rm temp_stat_cpc.csv")		
	
	
	
	
		if (fileexists("out.csv")) then
		system("rm out.csv")
		title="estatisticas mensais clima"
		asciiwrite("out.csv",title)
	else
		title="estatisticas mensais clima"
		asciiwrite("out.csv",title)
	end if
	if (fileexists("temp_stat_cpc.csv")) then
		system("rm temp_stat_cpc.csv")
	end if 
	do k=0,num_rec-1
	
		title=sprinti("%02i",k)+" "+tempos_statall(k)
		opt@title=title
		b:=statall(:,k,:)
		c:=b(valor|:,bacia|:)
		c@_FillValue=-1
		write_matrix(c,fmt,opt)
		system("cat temp_stat_cpc.csv >> out.csv")
	end do
	system("mv out.csv "+config@output_stat+"_ano_mes.csv") 
	system("rm temp_stat_cpc.csv")		
		
	;
	; gravar 15 dias
	;	
	title1=sprinti("%02i",tempos(:,0))+" "+sprinti("%02i",tempos(:,1))+" "+sprinti("%02i",tempos(:,2))+" "+sprinti("%02i",tempos(:,3))
   
	do j=0,3
		do i=0,num_bacias-1
			title1=title1+sprintf(" %10.4f",soma(j,:,i)) 
		end do
	end do
	alist=[/title1/]
	write_table(config@output_stat+"_soma.csv","w",alist,"%s") 

    
	m1=statall(:,:,0)
	m2=m1(time|:,bacia|:)
	
	linhafim=tempos_statall
	linhafim2=tempos_statall
	do i=0,num_rec-1
		linha=" "
		linha2=" "
		do j=0,num_bacias-1
			 linha=linha+sprintf("%10.4f",statall(j,i,0))
			 linha2=linha2+sprintf("%10.4f",statall(j,i,14))
		end do
		linhafim(i)=linhafim(i)+linha
		linhafim2(i)=linhafim2(i)+linha2
		
	end do		
			 
			 
	alist=[/linhafim/] 
	blist=[/linhafim2/] 
	write_table(config@output_stat+"_linear.csv","w",alist,"%s") 
	write_table(config@output_stat+"_linear.csv","a",blist,"%s") 
		
		
end 
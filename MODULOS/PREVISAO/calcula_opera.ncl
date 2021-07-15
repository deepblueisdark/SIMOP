load "$NCARG_ROOT/lib/ncarg/nclscripts/contrib/cd_inv_string.ncl"


;
; cria arquivo de status sobre as execucçoes
;  .status_calcula.dat ==> 0 rodou -1 não rodou 
;   status_calcula.dat  ==> log com as rodadas 
;  
;  config@modelo
;  config@status 
;  config@codmodelo 
;  config@status
;  config@datarun 
;  config@rodada
;  
function put_status(  STATUS,config) 
begin

	id=stringtointeger(config@codmodelo)
	STATUS(id)=config@status
	asciiwrite(".status_calcula.dat",STATUS)
	alist=[/config@modelo,config@codmodelo,config@status,config@datarun,config@rodada/] 
	write_table("status_calcula.dat","a",alist,"%s %s %d %s %s")
	return(0)
end


;
;
;  caclula estatisticas gerais
;  usando stat_dispersion
;
;
;  config@arq_de_bacias
;  config@num_bacias
;  config@input_stat  
;  config@units
;
;
;

function  stat_calcula(config)
begin
	
    ;
	;  le arquivo de bacias
	;
	nrow = numAsciiRow(config@arq_de_bacias)
	ncol = numAsciiCol(config@arq_de_bacias)
	if (config@num_bacias .ne. 0  ) then 
		num_bacias=config@num_bacias
	else
		num_bacias=tointeger(ncol/2)
	end if
	print("Numero de bacias:"+num_bacias) 
	bacias = readAsciiTable(config@arq_de_bacias, 1, "string",nrow-1)
	list_bacias=bacias(0,0)
	nome_bacias=str_split(list_bacias," ") 
	;
	; le arquivo de pre-estatitisca 
	;
	nrow = numAsciiRow(	config@input_stat)
	ncol = numAsciiCol(	config@input_stat)
	base = readAsciiTable(	config@input_stat, ncol, "float",0)
    ;printVarSummary(base)
	units=config@units
	;
	;   cria matriz tempos
	;
	id_tempos=tointeger(cd_inv_calendar(base(:,1),base(:,2),base(:,3),base(:,4),base(:,4),base(:,4),units,0))
	itime_max=tointeger(max(id_tempos))
	itime_min=tointeger(min(id_tempos))
	;
	; cria matriz de trabalho a partir do arquivo de estattisdtica
	;
	chuva=new((/itime_max+1,num_bacias+1,200/),"float") 
	;
	;
	do i=0,nrow-1
		do j=0,num_bacias-1
		     ;print(i+" "+j+" "+base(i,0))
			chuva(tointeger(id_tempos(i)),j,tointeger(base(i,0)))=base(i,j+5) 
		end do
    end do
	;
	; cria matrix stat 
	;
	g=new((/itime_max,30,num_bacias/),"float",-1)
	opt=False
	do t=itime_min,itime_max-1
		do j=0,num_bacias-1
			g(t,:,j)=stat_dispersion(chuva(t,j,:),opt)
			;
			;  22,23 e 24 só funciona para n=1000 por isso 
			; uso para outros calculos
			; 
			;  22 = media dos percentis altos
			;  23  = ,edia dos percentis baixos
			;  24  = diferença entre a média e o maximo dos maximos
			;
			g(t,22,j)=(g(t,11,j)+g(t,12,j)+g(t,13,j))/3
			g(t,23,j)=(g(t,3,j)+g(t,4,j)+g(t,5,j))/3
			g(t,24,j)=(g(t,14,j)-g(t,10,j)) 
			
		end do
	end do 		
	;
	;  apenas  para  plotar valores das estatisticas
	;
	; nStat = num(.not.ismissing(g(0,:,:)))
	; statLabel = new ( nStat, "string")
	;
	;
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
	opt=True
	opt@fout="temp_stat.csv"
	if (fileexists("out.csv")) then
		system("rm out.csv")
		title=list_bacias
		asciiwrite("out.csv",title)
	else
		title=list_bacias
		asciiwrite("out.csv",title)
	end if
	if (fileexists("temp_stat.csv")) then
		system("rm temp_stat.csv")
	end if 
	;
	;   cria a tabela e depois grava em arquivo
	;
    fmt=sprinti("%d",num_bacias)+"f10.4"
	do t=itime_min,itime_max-1
		;opt@title=sprinti("%02i",tointeger(base(t,0)))+" "+sprinti("%02i",tointeger(base(t,1)))+" "+sprinti("%02i",tointeger(base(t,2)))+" "+sprinti("%02i",tointeger(base(t,3)))
		title1=sprinti("%02i",tointeger(base(t,0)))+" "+sprinti("%02i",tointeger(base(t,1)))+" "+sprinti("%02i",tointeger(base(t,2)))+" "+sprinti("%02i",tointeger(base(t,3)))
		do i=0,num_bacias-5
			title=title1+" -99 "
			title1=title
		end do	
	    opt@title=title
		b=g(t,:,:)
	    b@_FillValue=-1
		write_matrix(b,fmt,opt)
		system("cat temp_stat.csv >> out.csv")
	end do
	system("mv out.csv "+config@stat_file) 
	system("rm temp_stat.csv")
	return(0)
end
	
;
;
;   le arquivo de bacias
;
;   config@arq_de_bacias
;    config@num_bacias
;
;
function le_arq_bacias (config)
begin
	nrow = numAsciiRow(config@arq_de_bacias)
	ncol = numAsciiCol(config@arq_de_bacias)
	if (config@num_bacias .ne. 0  ) then 
		num_bacias=config@num_bacias
	else
		num_bacias=tointeger(ncol/2)
	end if
	;print("Numero de bacias:"+num_bacias) 
    ;
	;  L~e dados de contornos das bacias   	
	;
	;print(nrow+"  t "+ncol)
	bacias = readAsciiTable(config@arq_de_bacias, ncol, "float",0)
	var = readAsciiTable(config@arq_de_bacias, 1, "string",nrow-1)
	bacias@list_bacias=var(0,0)
    bacias@ncol=ncol
	bacias@nrow=nrow
	bacias@num_bacias=num_bacias
	bacias@lista_bacias=var
   return(bacias) 


end


;
;  trata chuva gpm 
;
;
;
;

function get_chuva_obs( config) 
begin


	
	lista=config@input_list

	fi=addfiles(lista,"r")
	print(fi) 
	;vNames = getfilevarnames (fi[0])
	;atts=getfilevaratts(fi[0],"PREC_P0_L1_GLL0")
	;print(vNames)
	;print(atts)
	;
	; dimensoes
	;
	lat=fi[0]->lat_0
	lon=fi[0]->lon_0 
	d=dimsizes(config@input_list)
	num_tempos=d(0)
	print(num_tempos)
	NUM_DIAS_PREV=90
	;
	;
	;
	var=fi[0]->PREC_P0_L1_GLL0
	chuva=new((/num_tempos,dimsizes(lat),dimsizes(lon)/),"float") 
	;
	;
	;
	chuva!0="time"
	tempos=new((/num_tempos,4/),"integer") 
	copy_VarAtts(var, chuva)                    
	copy_VarCoords_1(var,chuva)
	initial_time=chuva@initial_time
	tempos@units="hours since "+initial_time
	
	;
	;
	;
	do n=0,d(0)-1
		var=fi[n]->PREC_P0_L1_GLL0
		chuva(n,:,:)=var
		tmp=var@initial_time
		tempos(n,1)=stringtoint(str_get_field(tmp,1,"/"))
		tempos(n,2)=stringtoint(str_get_field(tmp,2,"/"))
		tmp2=(str_get_field(tmp,3,"/"))
		tempos(n,0)=stringtoint(str_get_field(tmp2,1,"("))
		tmp=(str_get_field(tmp2,2,"("))
		tempos(n,3)=stringtoint(str_get_field(tmp,1,":"))
	end do
	chuva@initial_time=initial_time
	;
	;
	;
	
	bacias=le_arq_bacias(config)
	printVarSummary(bacias)
		if (config@num_bacias .ne. 0  ) then 
		num_bacias=config@num_bacias
	else
		num_bacias=bacias@num_bacias
	end if
	nome_bacias=str_split(bacias@list_bacias," ") 
	;
	;  cria as arrays de dados 
	;
	chuva_acu_h=new((/num_bacias+1,num_tempos/),float,chuva@_FillValue)
	chuva_acu_d=new((/num_bacias+1,NUM_DIAS_PREV/),float,chuva@_FillValue)
	chuva_acu_h=0.0
	chuva_acu_d=0.0
	chuva_med_h=chuva_acu_h
	chuva_med_d=chuva_acu_d
	;
	;  pega os potos de grade referentes as bacias
	;
	e=0
	b=0
	do bb=0,(num_bacias*2)-1,2
		if (b .ne. 0) then 
			delete(ilat)
			delete(ilon)
			delete(latx)
			delete(lonx)
		end if
		;
		;  pega pontos de grade de uma determinada bacia
		;
		;

		num_pontos=tointeger(bacias(0,bb))
		latx=bacias(1:num_pontos-1,bb+1)
		lonx=bacias(1:num_pontos-1,bb)+360
		;
		;  gera matriz de pontos de grade que cointem no bacia 
		;
		ilat=ind_nearest_coord (latx, lat, 0)
		ilon=ind_nearest_coord (lonx, lon, 0)
		;
		; faz a soma da chuva para calcula da média
		;
		print("Processando:"+nome_bacias(b)+" Com "+num_pontos+" pontos de grade") 
		;
		;
		;
		tt=0
		tempo_atual=tempos(0,2)
		data_str_d=new((/NUM_DIAS_PREV+1/),"string")
		data_str_d2=data_str_d
		data_str_d(0)=sprinti("%0.4i",tempos(0,0))+"/"+sprinti("%0.2i",tempos(0,1))+"/"+sprinti("%0.2i",tempos(0,2))+" "+sprinti("%0.4i",tempos(0,0))+" "+sprinti("%0.2i",tempos(0,1))+" "+sprinti("%0.2i",tempos(0,2))+" -99 -99 "
		;data_str_d2(0)=sprinti("%0.4i",tempos(0,0))+" "+sprinti("%0.2i",tempos(0,1))+" "+sprinti("%0.2i",tempos(0,2))

		;
		;  processa os dados
		;
		do t=0,num_tempos-1
			;
			;   verifica se muda a hora para mudar o dia 
			;
			if (tempo_atual .ne. tempos(t,2) ) then 
				tempo_atual=tempos(t,2)
				tt=tt+1
				;print(tt+"")
				data_str_d(tt)=sprinti("%0.4i",tempos(t,0))+"/"+sprinti("%0.2i",tempos(t,1))+"/"+sprinti("%0.2i",tempos(t,2))+" "+sprinti("%0.4i",tempos(t,0))+" "+sprinti("%0.2i",tempos(0,1))+" "+sprinti("%0.2i",tempos(0,2))+" -99 -99 "
				;data_str_d2(tt)=sprinti("%0.4i",tempos(t,0))+" "+sprinti("%0.2i",tempos(t,1))+" "+sprinti("%0.2i",tempos(t,2))
				
			end if
			;
			;  processa os daods. dados horarios e dados diarios
			;
			do k=0,dimsizes(ilat)-1
				n = ilat(k)
				m = ilon(k)
				;print("T= "+t+" k="+k+" b="+b+" CLAT:"+latx(k)+"  CLON:"+lonx(k)+" N="+n+" M="+m+" LAT="+lat(n)+" LON="+lon(m)+"="+chuva(t,n,m))
				if(ismissing(chuva(t,n,m))) then
						chuva_acu_h(b,t)=0.0
						chuva_acu_d(b,tt)=0.0
				else
						chuva_acu_h(b,t)=chuva_acu_h(b,t)+chuva(t,n,m)
						chuva_acu_d(b,tt)=chuva_acu_d(b,tt)+chuva(t,n,m) 
				end if	
				
			end do
		end do
	
		;
		;
			
		chuva_med_h(b,:)=chuva_acu_h(b,:)/num_pontos
		chuva_med_d(b,:)=chuva_acu_d(b,:)/num_pontos
		 
		b=b+1
	end do
	
	input=config@input
	output_d=config@output_d
	output_h=config@output_h
	modelo=config@modelo
	codmodelo=config@codmodelo
	modo=config@modo
	
	labeldata="MODELO CODMODEL ID DATA ANO MES DIA HORA ENS"
    hlist=[/labeldata,bacias@list_bacias/]
	;
	; grava dados horarios 
	;	
	write_table(config@output_h,"w",hlist,"%s %s %s %s")
	do t=0,num_tempos-1
       valores_str=new((/b/),"string") 
	   data_str=sprinti("%0.4i",tempos(t,0))+"/"+sprinti("%0.2i",tempos(t,1))+"/"+sprinti("%0.2i",tempos(t,2))+" "+sprinti("%0.4i",tempos(t,0))+" "+sprinti("%0.2i",tempos(t,1))+" "+sprinti("%0.2i",tempos(t,2))+" "+sprinti("%0.2i",tempos(t,3))+" -99 "
	
		do i=0,b-1
			valores_str(i)=sprintf("%5.2f ",chuva_med_h(i,t)) 
			;print(i+" "+t+" "+chuva_med_h(i,t)+" "+data_str)
		end do 

		linha_valores=str_join(valores_str," ") 
		alist=[/modelo, codmodelo, t , data_str , linha_valores/] 
		write_table(output_h,"a",alist,"%s %s %0.2d %s  %s")
		;blist=[/codmodelo,t,data_str,linha_valores/]
		;write_table(".tempobs_h.csv","a",blist,"%s %0.2d %s  %s")
		delete(linha_valores)
		delete(valores_str)
	end do 

	;
	; grava dados diarios 
	;
	write_table(output_d,"w",hlist,"%s %s %s %s")
	do t=0,tt-1
	    valores_str=new((/b/),"string") 
		do i=0,b-1
			valores_str(i)=sprintf("%7.2f ",chuva_med_d(i,t)) 
		end do 
		linha_valores=str_join(valores_str," ") 
		alist=[/modelo, codmodelo, t , data_str_d(t) , linha_valores/] 
		
		write_table(output_d,"a",alist,"%s %s %0.2d %s  %s")
		;blist=[/codmodelo,t,data_str_d2(t),linha_valores/]
		;write_table(".tempobs_d.csv","a",blist,"%s %0.2d %s  %s")
		delete(linha_valores)
		delete(valores_str)
	end do 	
	return(0)
end

;
;
;
;
;
function get_gfs_opendap( config )
begin
	print(config)
	;
	; t0
	;
	st=new(10,"float")
	st(0)=get_cpu_time()
	;
	;
	;
	input=config@input
	output_d=config@output_d
	output_h=config@output_h
	
	modelo=config@modelo
	codmodelo=config@codmodelo
	modo=config@modo
	;
	;  testa se tudo ok com abertura do arquivo 
	;	
	exists = isfilepresent(input)
	if(.not.exists) then
		print("OPeNDAP test unsuccessful.")
		print("Either the file doesn't exisT")
		print("not have OPeNDAP cabilities on this system.")
		return(-1)
	else
		fi = addfile(input,"r")
	end if
	;
	;  se precisar ver os atributros
	;
	;print(fi)
	;fAtts = getfileatts(fi)
    ;do na=0,dimsizes(fAtts)-1
	;	print ("fi@" + fAtts(na) + " = " + fi@$fAtts(na)$)
	;	end do
	;
	titulo=fi@title

	if (isvar("titulo")) then 
		print( "Arquivo:"+input+" abriu direito")
	else
		print( "problemas ao abrir arquivo opendap:"+input)
		return(-1) 
	end if 	
	;print(titulo)
	;
	;  dimensoes do arquivo   
	;
	dNames = getfiledimnames(fi)     ; NCL V6.5.0 and later
	dSizes = getfiledimsizes(fi)  
	;print (dNames+"   "+dSizes)
	;
	;  avalia se tem ou não ens e dessa forma cria conforme o caso as arrays
	;
	if (dNames(0) .eq. "ens") then 
		num_ens=dSizes(0)
		num_lat=dSizes(1)
		num_lev=dSizes(2)
		num_lon=dSizes(3)
		num_tempos=dSizes(4)
	else
		num_ens=1
		num_lat=dSizes(0)
		num_lev=dSizes(1)
		num_lon=dSizes(2)
		num_tempos=dSizes(3)
	end if 	
	;
	; lê coords
	;
	lat=fi->lat
	lon=fi->lon
	;
	; lÊ tempo
	;
	time=fi->time
	;print(time)
	tempos=tointeger(cd_calendar(time,0))	
	dt=(time@resolution)*24 
	;print("Numero de tempos processaveis:"+(num_tempos*dt/24))
	;
	; numero de dias de previsao 
	;
    NUM_DIAS_PREV=tointeger(((num_tempos*dt/24)+1))
	;
	; lê chuva ( verifica se tem ens ) 
	;
	if (dNames(0) .eq. "ens") then 	
		;
		;  depenednedo da fonte ,pode se usar prate ou apcpsfc
		;
		if (config@tipo_var_chuva .eq. "prate" ) then 
			chuva=fi->pratesfc*dt*3600
		else		
			chuva=fi->apcpsfc
		end if 	
	else
		chuva=new((/num_ens,num_tempos,num_lat,num_lon/),"float")
		if (config@tipo_var_chuva .eq. "prate" ) then 
			var=fi->pratesfc*dt*3600
		else		
			var=fi->apcpsfc
		end if 	
		chuva(0,:,:,:)=var
		copy_VarAtts(var, chuva)                    
		copy_VarCoords_1(var,chuva)
	end if 
	;printVarSummary(chuva)
	;
	; dimensoes de numero de bacias 
	;
	

	;print("Numero de ensembles:"+num_ens+"  Numero de tempos:"+num_tempos+" Numero de dias de previsao:"+NUM_DIAS_PREV)
	st(1)=get_cpu_time()
	;print("Leitura dos dados:"+(st(1)-st(0))) 

	; printVarSummary
	; lê arquivos de pontos de grade dentro de um determinado contorno
	;
	nrow = numAsciiRow(config@arq_de_bacias)
	ncol = numAsciiCol(config@arq_de_bacias)
	if (config@num_bacias .ne. 0  ) then 
		num_bacias=config@num_bacias
	else
		num_bacias=tointeger(ncol/2)
	end if
	;print("Numero de bacias:"+num_bacias) 
    ;
	;  L~e dados de contornos das bacias   	
	;
	;print(nrow+"  t "+ncol)
	data = readAsciiTable(config@arq_de_bacias, ncol, "float",0)
	bacias = readAsciiTable(config@arq_de_bacias, 1, "string",nrow-1)
	list_bacias=bacias(0,0)
	nome_bacias=str_split(list_bacias," ") 
	st(2)=get_cpu_time()
	;print("Leitura dos pontos de grade:"+(st(2)-st(1))) 
	;
	;
	;
		;
	;  cria as arrays de dados 
	;
	chuva_acu_h=new((/num_bacias+1,num_ens,num_tempos/),float,chuva@_FillValue)
	chuva_acu_d=new((/num_bacias+1,num_ens,NUM_DIAS_PREV/),float,chuva@_FillValue)
	chuva_acu_h=0.0
	chuva_acu_d=0.0
	chuva_med_h=chuva_acu_h
	chuva_med_d=chuva_acu_d
	;
	;  pega os potos de grade referentes as bacias
	;
	e=0
	b=0
	do bb=0,(num_bacias*2)-1,2
		if (b .ne. 0) then 
			delete(ilat)
			delete(ilon)
			delete(latx)
			delete(lonx)
		end if
		;
		;  pega pontos de grade de uma determinada bacia
		;
		;

		num_pontos=tointeger(data(0,bb))
		latx=data(1:num_pontos-1,bb+1)
		lonx=data(1:num_pontos-1,bb)+360
		;
		;  gera matriz de pontos de grade que cointem no bacia 
		;
		ilat=ind_nearest_coord (latx, lat, 0)
		ilon=ind_nearest_coord (lonx, lon, 0)
		;
		; faz a soma da chuva para calcula da média
		;
		print("Processando:"+nome_bacias(b)+" Com "+num_pontos+" pontos de grade") 
		;
		;
		;
		tt=0
		tempo_atual=tempos(0,2)
		data_str_d=new((/20/),"string")
		data_str_d2=data_str_d
		data_str_d(0)=sprinti("%0.4i",tempos(0,0))+"/"+sprinti("%0.2i",tempos(0,1))+"/"+sprinti("%0.2i",tempos(0,2))+" 99 "+sprinti("%0.4i",tempos(0,0))+" "+sprinti("%0.2i",tempos(0,1))+" "+sprinti("%0.2i",tempos(0,2))
		data_str_d2(0)=sprinti("%0.4i",tempos(0,0))+" "+sprinti("%0.2i",tempos(0,1))+" "+sprinti("%0.2i",tempos(0,2))

		;
		;  processa os dados
		;
		do t=0,num_tempos-1
			;
			;   verifica se muda a hora para mudar o dia 
			;
			if (tempo_atual .ne. tempos(t,2) ) then 
				tempo_atual=tempos(t,2)
				tt=tt+1
				data_str_d(tt)=sprinti("%0.4i",tempos(t,0))+"/"+sprinti("%0.2i",tempos(t,1))+"/"+sprinti("%0.2i",tempos(t,2))+" 99 "+sprinti("%0.4i",tempos(t,0))+" "+sprinti("%0.2i",tempos(0,1))+" "+sprinti("%0.2i",tempos(0,2))
				data_str_d2(tt)=sprinti("%0.4i",tempos(t,0))+" "+sprinti("%0.2i",tempos(t,1))+" "+sprinti("%0.2i",tempos(t,2))
				
			end if
			;
			;  processa os daods. dados horarios e dados diarios
			;
			do k=0,dimsizes(ilat)-1
				n = ilat(k)
				m = ilon(k)
				do e=0,num_ens-1
					;print("T= "+t+" k="+k+" b="+b+" CLAT:"+latx(k)+"  CLON:"+lonx(k)+" N="+n+" M="+m+" LAT="+lat(n)+" LON="+lon(m)+"="+chuva(e,t,n,m))
					if(ismissing(chuva(e,t,n,m))) then
						chuva_acu_h(b,e,t)=0.0
						chuva_acu_d(b,e,tt)=0.0
					else
						chuva_acu_h(b,e,t)=chuva_acu_h(b,e,t)+chuva(e,t,n,m)
						chuva_acu_d(b,e,tt)=chuva_acu_d(b,e,tt)+chuva(e,t,n,m) 
					end if	
				end do
			end do
		end do
		;
		;
		;
		st(3)=get_cpu_time()
		;print("Processado bacia:"+(st(3)-st(2)))
		;
		;
		;
		do e=0,num_ens-1		
			chuva_med_h(b,e,:)=chuva_acu_h(b,e,:)/num_pontos
			chuva_med_d(b,e,:)=chuva_acu_d(b,e,:)/num_pontos
		end do 
		b=b+1
	end do
	;print(chuva_acu_h+" "+chuva_med_h)
	;print(chuva_acu_d+" "+chuva_med_d)
	 
	 
	 labeldata="MODELO CODMODEL ID DATA ANO MES DIA HORA ENS"
     hlist=[/labeldata,list_bacias/]
	 
	
	;
	; grava dados horarios 
	;	
	do e=0,num_ens-1	
		if (e .eq. 0 .and. config@modo ) then 
			write_table(output_h,"w",hlist,"%s %s %s %s")
		else
			;write_table(output_h,"a",hlist,"%s %s %s %s")
        end if 
		
		
		do t=0,num_tempos-1
		    valores_str=new((/b/),"string") 
	 		data_str=sprinti("%0.4i",tempos(t,0))+"/"+sprinti("%0.2i",tempos(t,1))+"/"+sprinti("%0.2i",tempos(t,2))+" "+sprinti("%0.2i",tempos(t,3))+" "+sprinti("%0.4i",tempos(t,0))+" "+sprinti("%0.2i",tempos(t,1))+" "+sprinti("%0.2i",tempos(t,2))
	
			do i=0,b-1
				valores_str(i)=sprintf("%5.2f ",chuva_med_h(i,e,t)) 
			end do 
			linha_valores=str_join(valores_str," ") 
			alist=[/modelo, codmodelo, t , data_str ,e, linha_valores/] 
			write_table(output_h,"a",alist,"%s %s %0.2d %s %0.2d %s")
			delete(linha_valores)
			delete(valores_str)
		end do 
	end do 
	;
	; grava dados diarios 
	;
	
	do e=0,num_ens-1	
		if (e .eq. 0 .and. config@modo ) then 
			write_table(output_d,"w",hlist,"%s %s %s %s")
		else
			;write_table(output_d,"a",hlist,"%s %s %s %s")
        end if 
		
		
		do t=0,tt-1
		    valores_str=new((/b/),"string") 
			
			do i=0,b-1
				valores_str(i)=sprintf("%7.2f ",chuva_med_d(i,e,t)) 
			end do 
			linha_valores=str_join(valores_str," ") 
			alist=[/modelo, codmodelo, t , data_str_d(t) ,e, linha_valores/] 
			blist=[/codmodelo,data_str_d2(t),e,linha_valores/]
			write_table(output_d,"a",alist,"%s %s %0.2d %s %0.2d %s")
			write_table(config@output_stat,"a",blist,"%s %s %0.2d %s")
			delete(linha_valores)
			delete(valores_str)
		end do 
	end do 	
	
	return(0) 
	
	
	
	
	
	
end
	
	
	





begin 


		
	
	EXECUTE_MODELS=getenv("EXECUTE_MODELS")
	EXECUTE_OBS=getenv("EXECUTE_OBS")
	EXECUTE_STAT=getenv("EXECUTE_STAT")
	config=True
	
	if (ismissing(EXECUTE_MODELS)) 
		EXECUTE_MODELS=True
	end if
	if (ismissing(EXECUTE_OBS)) 
		EXECUTE_OBS=True
	end if	
	if (ismissing(EXECUTE_STAT)) 
		EXECUTE_STAT=True
	end if	
	datarun=getenv("DATARUN") 
	if (ismissing(datarun)) 
		datarun=systemfunc("date +'%Y%m%d'") 
	end if 
	
	TIME_UNITS=getenv("TIME_UNITS")
	if (ismissing(TIME_UNITS))
		config@units=systemfunc("date +'days since  %Y-%m-%d 00:00:00'")
	else
		config@units=TIME_UNITS 
	end if 
	
	
	rodada=getenv("RODADA") 
	if (ismissing(rodada)) 
		rodada="00"
	end if 

	




	NUM_MODELOS=stringtointeger(getenv("NUM_MODELOS"))
		if (ismissing(NUM_MODELOS)) 
		NUM_MODELOS=35
	end if
	if (rodada .eq. "00" ) then 
		INC_MOD=0
	end if
	if (rodada .eq. "06" ) then 
		INC_MOD=(NUM_MODELOS)
	end if
	if (rodada .eq. "12" ) then 
		INC_MOD=((NUM_MODELOS)*2)
	end if
	if (rodada .eq. "18" ) then 
		INC_MOD=((NUM_MODELOS)*3)
	end if
	
	print(INC_MOD+" "+NUM_MODELOS)

	
	
	NUM_BACIAS=stringtointeger(getenv("NUM_BACIAS"))
	NUM_ENS=stringtointeger(getenv("NUM_ENS"))
	NUM_MAX_TEMPOS=stringtointeger(getenv("NUM_MAX_TEMPOS")) 
    ARQ_BACIAS=getenv("ARQ_BACIAS")
	RESTART=getenv("RESTART")
	if (ismissing(ARQ_BACIAS)) 
		ARQ_BACIAS="/mnt/e/OPERACIONAL/PREVISAO/OMEGA_HICON.dat"
	end if
	

	
	if (ismissing(NUM_BACIAS)) 
		NUM_BACIAS=0
	end if	
	
	if (ismissing(NUM_ENS)) 
		NUM_ENS=1
	end if	

	if (ismissing("NUM_MAX_TEMPOS")) 
		NUM_MAX_TEMPOS=20
	end if	


	if (ismissing("RESTART")) 
		RESTART="False"
	end if	

	
	
	if (fileexists(".status_calcula.dat") .and. RESTART .eq. "True") then 
	STATUS=asciiread(".status_calcula.dat",(/200/),"integer")
	else
		STATUS=new((/200/),"integer",-1) 
	end if
	
	
	print("EXECUTE_MODELS:"+EXECUTE_MODELS) 
	print("EXECUTE_OBS   :"+EXECUTE_OBS) 
	print("EXECUTE_STAT  :"+EXECUTE_STAT) 
	print("DATARUN       :"+datarun) 
	print("RODADA        :"+rodada) 
	print("TIME_UNITS    :"+TIME_UNITS) 
	print("NUM MODELOS   :"+NUM_MODELOS)
	print("NUM BACIAS    :"+NUM_BACIAS)
	print("RESTART       :"+RESTART)

	
	;
    fontes=new((/NUM_MODELOS+1,4/),"string")
	urldods="http://nomads.ncep.noaa.gov:80/dods/"
	
	fontes(0,0)="http://nomads.ncep.noaa.gov:80/dods/gfs_1p00/gfs"+datarun+"/gfs_1p00_"+rodada+"z"
	fontes(0,1)="GFS1P00H03T"+rodada+"E00"
	fontes(0,2)=sprinti("%02d",INC_MOD)
	fontes(0,3)=rodada
	;
	;
	;
	fontes(1,0)="http://nomads.ncep.noaa.gov:80/dods/gfs_0p50/gfs"+datarun+"/gfs_0p50_"+rodada+"z"
	fontes(1,1)="GFS0P50H03T"+rodada+"E00"
	fontes(1,2)=sprinti("%02d",1+INC_MOD)
	fontes(1,3)=rodada
	;
	;
	;
	fontes(2,0)="http://nomads.ncep.noaa.gov:80/dods/gfs_0p25/gfs"+datarun+"/gfs_0p25_"+rodada+"z"
	fontes(2,1)="GFS0P25H03T"+rodada+"E00"
	fontes(2,2)=sprinti("%02d",2+INC_MOD)
	fontes(2,3)=rodada
	;
	;
	;
	fontes(3,0)="http://nomads.ncep.noaa.gov:80/dods/gfs_0p25_1hr/gfs"+datarun+"/gfs_0p25_1hr_"+rodada+"z"
	fontes(3,1)="GFS0P25H01T"+rodada+"E00"
	fontes(3,2)=sprinti("%02d",3+INC_MOD)
	fontes(3,3)=rodada
	;
	;
	;
	fontes(4,0)="http://nomads.ncep.noaa.gov:80/dods/gefs/gefs"+datarun+"/gec00_"+rodada+"z_pgrb2b"
	fontes(4,1)="GEFS0P50H06T"+rodada+"E00"
	fontes(4,2)=sprinti("%02d",4+INC_MOD)
	fontes(4,3)=rodada
	do i=1,30
		fontes(4+i,0)="http://nomads.ncep.noaa.gov:80/dods/gefs/gefs"+datarun+"/gep"+sprinti("%02d",i)+"_"+rodada+"z_pgrb2b"
		fontes(4+i,1)="GEFS0P50H06T"+rodada+"E"+sprinti("%02d",i)
		fontes(4+i,2)=sprinti("%02d",(i+4)+INC_MOD)
		fontes(4+i,3)=rodada
	end do


	;
	;
	;
	;base=new((/NUM_MODELOS,NUM_BACIAS,NUM_ENS,NUM_MAX_TEMPOS/),"float")  
	config=True
	config@datarun=datarun
	config@num_modelos=NUM_MODELOS*3
	config@modo=True
	config@tipo_var_chuva="prate"
	config@input=fontes(0,0)
	if (RESTART .eq. "False") then 
		config@output_h="multmodels_h_"+datarun+rodada+".csv"
		config@output_d="multmodels_d_"+datarun+rodada+".csv"
	else
		config@output_h="multmodels_h_"+datarun+rodada+"_restart.csv"
		config@output_d="multmodels_d_"+datarun+rodada+"_restart.csv"
	end if
	
	config@output_stat=".stat_tmp_"+datarun+rodada+".csv"
	config@modelo=fontes(0,1)
	config@codmodelo=fontes(0,2)
	config@rodada=rodada
	config@num_bacias=0
	config@arq_de_bacias=ARQ_BACIAS

	
	
	if (EXECUTE_MODELS .eq.  "True" .and. RESTART .eq. "False" )  then 
		;pi=get_gfs_opendap(config) 
		;#config@status=get_gfs_opendap(config)
		;ik=put_status(STATUS,config) 

		do i=0,34
			config@modo=False                  ;;; se cria um arquivo unico ou separado 
			config@input=fontes(i,0)
			config@modelo=fontes(i,1)
			config@codmodelo=fontes(i,2)
			config@rodada=rodada
			config@status=get_gfs_opendap(config)
			ik=put_status(STATUS,config) 				
			
		end do	
		
	end if 
	

	if (EXECUTE_MODELS .eq.  "True" .and. RESTART .eq. "True" )  then 
		 
		if (STATUS(0) .eq. -1 ) 
			config@status=get_gfs_opendap(config)
			ik=put_status(STATUS,config) 
		end if
		do i=1,34
			config@modo=False                  ;;; se cria um arquivo unico ou separado 
			config@input=fontes(i,0)
			config@modelo=fontes(i,1)
			config@codmodelo=fontes(i,2)
			config@rodada=rodada
			if (STATUS(i) .eq. -1 ) then 
				config@status=get_gfs_opendap(config)
				ik=put_status(STATUS,config) 				
			end if 
		end do	
		

	end if 
	
	

	if ( EXECUTE_STAT .eq.  "True" ) then

		config@input_stat=config@output_stat
		config@stat_file="multmodels_stat_"+datarun+rodada+".csv"
		if fileexists(config@output_stat) then 
			p=stat_calcula(config)
		end if 
	end if

	if ( EXECUTE_OBS .eq.  "True" ) then
	
			config@input_list=systemfunc("ls -1 /mnt/d/DADOS/OBS/CHUVAOBS/MERGE_CPTEC_HORARIO_GPM_11KM/GRIB/MERGE_CPTEC_20201*.grib2")
			DIAS_OBS=31
			ultima_hora=systemfunc("date +'%H' -d'2 hours ago'")
			num_horas=(DIAS_OBS*24)+ultima_hora
			;lista_obs=NewList("lifo")
			;do i=num_horas,0,1
			;	link="/mnt/d/DADOS/OBS/CHUVAOBS/MERGE_CPTEC_HORARIO_GPM_11KM/GRIB/"
			;	datagpm=systemfunc("date +'%Y%m%d%H' -d'"+sprinti("%d",i)+" hours ago'")
			;	filegpm="MERGE_CPTEC_"+datagpm+".grib2"
			;
			;	ListPush(lista_obs,link+filegpm) 
			;end do 
			config=True
			config@modo=True
			config@tipo_var_chuva="prate"
			;config@input_list=lista_obs
			config@modelo="GPM0P11"
			config@codmodelo="00"
			config@rodada=rodada
			config@tipo_var_chuva="prate"
			config@output_h="chuva_observada_h_"+datarun+rodada+".csv"
			config@output_d="chuva_observada_d_"+datarun+rodada+".csv"
			config@output_stat="chuva_observada_stat_"+datarun+rodada+".csv"
			p2=get_chuva_obs(config)
	end if 
end
 	
	

 	


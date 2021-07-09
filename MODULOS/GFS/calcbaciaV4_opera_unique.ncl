load "$NCARG_ROOT/lib/ncarg/nclscripts/contrib/cd_inv_string.ncl"
 

;
; calcula media numa bacia 
; 
;  
function calcbacia( data , lat , lon , shapefile, lon360)  
begin
	;
	; dimensoes 
	;
	nlat=dimsizes(lat)
	nlon=dimsizes(lon) 
	;
	; matriz de trabalhos
	;
	data_mask = new(dimsizes(data),typeof(data),data@_FillValue)
	copy_VarCoords(data,data_mask)
	;
	;  abre o arquivo e verifica se lon é 360 ou -180 
	;
	f=addfile(shapefile, "r")
	if (lon360)
	mrb_lon = f->x
	else
	mrb_lon = f->x+360
	end if
	mrb_lat = f->y
	nmrb    = dimsizes(mrb_lon)
    ;
    ; min e max lat
    ;
	min_mrb_lat = min(mrb_lat)
	max_mrb_lat = max(mrb_lat)
	min_mrb_lon = min(mrb_lon)
	max_mrb_lon = max(mrb_lon)
	;
	; limites do dhape files
	;
	limites_shp=((/min_mrb_lat,min_mrb_lon,max_mrb_lat,max_mrb_lon/))
	;
	; processo inpolyline . verifica problema de lar invertida
	;
	if (lat(0) .eq. 90.00 )
		;print(" GFS lat invertida encontrada ") 
		ilt_mn = ind(min_mrb_lat.lt.lat)
		ilt_mx = ind(max_mrb_lat.gt.lat)
		iln_mn = ind(min_mrb_lon.gt.lon)
		iln_mx = ind(max_mrb_lon.lt.lon)
		ilt2 = ilt_mn(dimsizes(ilt_mn)-1)    ; Start of lat box
		iln1   = iln_mn(dimsizes(iln_mn)-1)    ; Start of lon box
		ilt1   = ilt_mx(0)                     ; End of lat box
		iln2   = iln_mx(0)                     ; End of lon box
		;print(ilt1 +" "+iln1 +" "+ilt2 +" "+iln2) 
	else
		ilt_mn = ind(min_mrb_lat.gt.lat)
		ilt_mx = ind(max_mrb_lat.lt.lat)
		iln_mn = ind(min_mrb_lon.gt.lon)
		iln_mx = ind(max_mrb_lon.lt.lon)
		ilt1   = ilt_mn(dimsizes(ilt_mn)-1)    ; Start of lat box
		iln1   = iln_mn(dimsizes(iln_mn)-1)    ; Start of lon box
		ilt2   = ilt_mx(0)                     ; End of lat box
		iln2   = iln_mx(0)                     ; End of lon box
		;print(ilt1 +" "+iln1 +" "+ilt2 +" "+iln2) 
	end if
	;
	; pega dados que estão dnetro do shape
	;
	do ilt=ilt1,ilt2
		do iln=iln1,iln2
			
			if(gc_inout(lat(ilt),lon(iln),mrb_lat,mrb_lon)) then
			data_mask(ilt,iln) = data(ilt,iln)
			
        end if
      end do
    end do
	;
	; faz calculos da chuva media e  soma total da chuva
	; 
    num_pontos_inside=num(.not.ismissing(data_mask)) 
	soma = sum(data_mask) 
	if (num_pontos_inside .gt. 0 )
		media = sum(data_mask)/num_pontos_inside
	else
		media=0.000000001
	end if
    data_mask@num_pontos_inside=num_pontos_inside
	data_mask@soma=soma
	data_mask@media=media 
	data_mask@limites_shp=limites_shp
    return(data_mask)
end 


;
; config@lista_shapes
; config@tempo_inicial
; config@tempo_final
; config@lon360
; config@ens=13
; config@ensall=False 
;
function calcula_chuva_media_em_lote( data, lat ,lon, files_shp,config)
begin
	

	d=dimsizes(files_shp)
	num_shapes=d(0)
	delete(d)
	;
	; tempos
	;
	d=dimsizes(data)
	rank=dimsizes(d)
	;print(rank)
		;
		;
		M=new((/num_shapes/),"float")
		;
		;
		;
		do i=0,num_shapes-1
			
			chuva:=calcbacia(data,lat,lon,files_shp(i),config@lon360)
			M(i)=chuva@media
		end do

return(M)
end 







function calcula_chuva_media( fi, config ) 
begin 
    ;
	;  abre arquivos de shapes
	;
	files_shp=systemfunc("cat "+config@lista_shapes)
	d=dimsizes(files_shp)
	num_shapes=d(0)
	;
	; pega lsita de variaveis de chuva (prate, acpsc, ...)
	;	
	var_list=getfilevarnames(fi)
	;
	; abre lat/lon dimensoes
	;
	lat=fi->lat_0
	lon=fi->lon_0
	var=fi->$var_list(0)$ 
	;
	; obter a matrix de tempo 
	;
	horas=config@hora
	;print(horas)
	inicio=var@initial_time
	var2=str_split(inicio,"/")
	var3=str_split(var2(2),"(")
	var4=str_split(var3(1),")")
	units="hours since "+str_squeeze(var3(0))+"-"+var2(0)+"-"+var2(1)+" "+var4(0)+":00"
	horas@units=units
	tempos=tointeger(cd_calendar(horas,0))
	data_str=sprinti("%0.4i",tempos(:,0))+"/"+sprinti("%0.2i",tempos(:,1))+"/"+sprinti("%0.2i",tempos(:,2))+" "+sprinti("%0.4i",tempos(:,0))+" "+sprinti("%0.2i",tempos(:,1))+" "+sprinti("%0.2i",tempos(:,2))+" "+sprinti("%0.2i",tempos(:,3))
	;
	; imprime config
	;
	print(config)
	;
	; processa de acordo com modelo e a variavel de chuva
	;
	if (var_list(0) .eq. "APCP_P11_L1_GLL0_acc" .or. var_list(0) .eq. "APCP_P11_L1_GLL0_acc6h" ) then 
		print("[SIMOP - CALCBACIA GEFS0P25] - ACPC")
		;
		; passar de  kg m/s-1 para mm 
		;
		data=var
		ens=config@work_ens
		ensname=config@ensname
		;print(ensname)
	elseif  ( var_list(0) .eq.  "PRATE_P11_L1_GLL0_avg6h" .or. var_list(0) .eq. "PRATE_P11_L1_GLL0_avg" ) then 
		;
		; passar de  kg m/s-1 para mm 
		;
		print("[SIMOP - CALCBACIA GEFS0P50] - PRATE")
		data=var*6*3600
		ens=config@work_ens
		ensname=config@ensname
		data!0="lat"
		data!1="lon"
		data&lat=lat
		data&lon=lon
	elseif (var_list(0) .eq. "PRATE_P0_L1_GLL0"  ) then  
		;
		; passar de  kg m/s-1 para mm 
		;
		print("[SIMOP - CALCBACIA GFS] ")
		data=var*3*3600
		;printVarSummary(var)
		ens=config@work_ens
		ensname=config@ensname
		data!0="lat"
		data!1="lon"
		data&lat=lat
		data&lon=lon		
	end if 
	;
	;
	;
	config@tempos:=tempos
	;
	;  calcula chuva media
	;
	M=calcula_chuva_media_em_lote( data ,lat ,lon,files_shp, config)
	;
	; imprime relatorio
	;
	modelo=config@modelo
	d:=dimsizes(M)
	rank=dimsizes(d)
	;
	; concatena noems dos bacias
	;
	;
	; concatena noems dos bacias
	;
	lista_bacias="ENS DATA ANO MES DIA HORA "
	do i=0,num_shapes-1
		var:=str_split(files_shp(i),"/")
		var1=str_split(var(5),".") 
		lista_bacias=lista_bacias+" "+var1(0)
	end do	
	;
	;  escreve o cabeçario da tabela
	;
	hlist=[/lista_bacias/] 
	if (config@append)
	;write_table(config@output,"w",hlist,"%s")
	else
		write_table(config@output,"w",hlist,"%s")
	end if 
	;
	; escreve cada linha de dado
	;
	
	modelox=modelo+" "+sprinti("%02d",config@work_ens)+" "+config@datarun
		
	
	if (rank .eq. 2) then 
		num_tempos=d(0)
		do t=0,num_tempos-1
			valores_str:=new((/num_shapes/),"string") 
			do b=0,num_shapes-1
				valores_str(b)=sprintf("%5.2f",M(t,b)) 
			end do 
			linha_valores=str_join(valores_str," ")
			alist=[/modelox,data_str(t),linha_valores/]
			write_table(config@output,"a",alist, "%s %s %s") 
		
		end do	
		
	elseif (rank .eq. 1) then 
		num_tempos=1
		valores_str:=new((/num_shapes/),"string") 
		do b=0,num_shapes-1
			valores_str(b)=sprintf("%5.2f",M(b)) 
		end do 
		linha_valores=str_join(valores_str," ")
		alist=[/modelox,data_str(0),linha_valores/]
		write_table(config@output,"a",alist, "%s %s %s") 
	end if
	return(0)
end





begin 
   
	;
	; gera a data do dia 
	;
	; se past é fornecido como argumento ,calcula no passado. 
	;
	;
	if(isdefined("past")) then
	
		comp=sprinti(" '-d %d days ago'",past) 
		YYYYMMDD=systemfunc("date +%Y%m%d"+comp)
		
	else
		YYYYMMDD=systemfunc("date +%Y%m%d")
	end if
	print(" Trabalhando na data "+YYYYMMDD)
	;
	; ciclo 
	;
	if (isdefined("ciclo")) then 
		RODADA=sprinti("%02d",ciclo)

	else	
		RODADA="00"
	end if
	print(" Ciclo="+RODADA)
	;
	; abre config
	;
	config=True
	config@datarun=YYYYMMDD+" "+RODADA
	config@lon360=False
	config@output="gfs_saida2_"+YYYYMMDD+".csv"
	config@logerror=0 
	;
	;
	;
	if (isdefined("append")) then
		config@append=False          ;;; apendiciona
	else		
		config@append=True          ;;; apendiciona
	end if
	print(" Append final="+config@append)
	;	
	; 				lista de shapes
	;
	if (isdefined("lista_shapes") )
		print(" Lista Shapes="+lista_shapes)
		config@lista_shapes=lista_shapes
	else
		print(" Lista de Shapes não informado.")
		exit
	end if 
	;
	;        modelo 
	;
	if (isdefined("modelo") )	
		print(" Modelo="+modelo)
	else
		print (" Modelo não informado")
		exit
	end if 
	;
	; ensembles
	;
	if (isdefined("ensall"))	
		config@ensall=ensall
	else
		config@ensall=False
	end if 
	;
	;   ensembles
	;
	if (config@ensall) then 
		print(" Ensemble     = Todos")
		print(" Num.Ensembles= 1-30")
		config@work_ens=0
	else
		if (isdefined("work_ens"))	
				config@work_ens=work_ens
				print(" Ensemble="+work_ens)
				print(" Num.Ensembles=1")
		else
				print(" Sem trabalho com ensembles")
				config@work_ens=0
		end if	

	end if 
	;
	; 					tempos 
	;
	if (isdefined("hora")) then
		config@tempo_inicial=hora
		config@tempo_final=hora
	else
		if (modelo .eq. "GFS0P25") 
			config@tempo_inicial=0
			config@tempo_final=384
		elseif (modelo .eq. "GEFS0P25")
			config@tempo_inicial=0
			config@tempo_final=240		
		elseif (modelo .eq. "GEFS0P50")
			config@tempo_inicial=0
			config@tempo_final=384	
		end if
	end if
	print(" Hora inicial="+config@tempo_inicial) 
	print(" Hora Final="+config@tempo_final) 
	;
	; processa
	;
	if ( modelo .eq. "GFS0P25") then 
		config@modelo="GFS0P25"
		config@work_ens=0 
		do h=config@tempo_inicial,config@tempo_final,3
			HORA=sprinti("%03d",h)
			config@hora=h
			config@ensname="gfs00"
			config@input="/mnt/d/DADOS/CICC/GRIB/GEFS/"+YYYYMMDD+"/"+"GFS0P25_gfs_"+RODADA+"_"+YYYYMMDD+"_"+HORA+".grib2"
			if (fileexists(config@input)) then
				fi:=addfile(config@input,"r")
				pi:=calcula_chuva_media( fi,config)
			else 
				mensagem=config@input+" Não encontrado"
				config@logerror=config@logerror+1
				asciiwrite("log.error",mensagem)      
			end if	
		end do 	
	elseif ( modelo .eq. "GEFS0P25") 
		config@modelo="GEFS0P25"
		do e=0,30 
		    if (e.eq. 0 )
				nome_ens="gec00"
			else
				nome_ens="gep"+sprinti("%02d",e)
			end if
			config@ensname=nome_ens
			config@work_ens=e+1
			do h=6,240,6		
				HORA=sprinti("%03d",h)
				config@hora=h
				config@input="/mnt/d/DADOS/CICC/GRIB/GEFS/"+YYYYMMDD+"/"+"GEFS0P25_"+nome_ens+"_"+RODADA+"_"+YYYYMMDD+"_"+HORA+".grib2"
				if (fileexists(config@input)) then
					fi:=addfile(config@input,"r")
					pi:=calcula_chuva_media( fi,config)
			else 
				mensagem=config@input+" Não encontrado"
				config@logerror=config@logerror+1
				asciiwrite("log.error",mensagem)      
			end if	
			end do
		end do		
	elseif (modelo.eq. "GEFS0P50")  	
			config@modelo="GEFS0P50"
			do e=0,30 
				if (e.eq. 0 )
					nome_ens="gec00"
				else
				nome_ens="gep"+sprinti("%02d",e)
			end if
			config@ensname=nome_ens
			config@work_ens=e+1
			do h=6,384,6		
				HORA=sprinti("%03d",h)
				config@hora=h
				config@input="/mnt/d/DADOS/CICC/GRIB/GEFS/"+YYYYMMDD+"/"+"GEFS0P50_"+nome_ens+"_"+RODADA+"_"+YYYYMMDD+"_"+HORA+".grib2"
				if (fileexists(config@input)) then
					fi:=addfile(config@input,"r")
					pi:=calcula_chuva_media( fi,config)
			else 
				mensagem=config@input+" Não encontrado"
				config@logerror=config@logerror+1
				asciiwrite("log.error",mensagem)      
			end if	
			end do
		end do		
	end if 
print("fim")



end




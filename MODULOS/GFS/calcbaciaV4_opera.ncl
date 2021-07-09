load "$NCARG_ROOT/lib/ncarg/nclscripts/contrib/cd_inv_string.ncl"
 








 
;
; calcula media numa bacia 
; 
;  
function calcbacia( data , lat , lon , shapefile, lon360)  

begin

   
	nlat=dimsizes(lat)
	nlon=dimsizes(lon) 

	data_mask = new(dimsizes(data),typeof(data),data@_FillValue)
	copy_VarCoords(data,data_mask)

	f=addfile(shapefile, "r")
	if (lon360)
	mrb_lon = f->x
	else
	mrb_lon = f->x+360
	end if
	mrb_lat = f->y
	nmrb    = dimsizes(mrb_lon)
   
	min_mrb_lat = min(mrb_lat)
	max_mrb_lat = max(mrb_lat)
	min_mrb_lon = min(mrb_lon)
	max_mrb_lon = max(mrb_lon)
	
	limites_shp=((/min_mrb_lat,min_mrb_lon,max_mrb_lat,max_mrb_lon/))
	

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
	
	do ilt=ilt1,ilt2
		do iln=iln1,iln2
			
			if(gc_inout(lat(ilt),lon(iln),mrb_lat,mrb_lon)) then
			data_mask(ilt,iln) = data(ilt,iln)
			
        end if
      end do
    end do

    
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





function plota_com_shape( data , shapefile , config)
begin 


  

	
 	res                       = True 
	res@gsnDraw             = False          ; don't draw plot yet

	res@gsnFrame            = False          ; don't advance frame yet
	res@gsnAddCyclic          = False
	 
	if (config@areashape) 
		limite=data@limites_shp
		res@mpMinLatF			  = limite(0)
		res@mpMaxLatF             = limite(2)
		res@mpMinLonF             = limite(1)-360
		res@mpMaxLonF             = limite(3)-360
	else 
		res@mpMinLatF			  = config@minlat
		res@mpMaxLatF             = config@maxlat
		res@mpMinLonF             = config@minlon
		res@mpMaxLonF             = config@maxlon
		res@mpCenterLonF          = config@centerlon
	end if 
	
	res@mpLimitMode           ="latlon"
	res@gsnMaximize           = True              ; Maximize plot
    res@cnFillOn              = True              ; color plot desired
    res@cnFillMode            = "RasterFill"      ; USES LESS MEMORY AND IS FASTER
    res@cnFillPalette         = "WhViBlGrYeOrRe"
    res@cnLinesOn             = False             ; turn off contour lines
    res@cnLineLabelsOn        = False    
	
	res@pmTickMarkDisplayMode = "Always"
	res@mpGridAndLimbOn       = "True" 
	res@mpGridLatSpacingF     = 5
	res@mpGridLonSpacingF	  = 5
	res@gsnMajorLatSpacing 	  = 1              ; change maj lat tm spacing
    res@gsnMajorLonSpacing    = 1              ; change maj lon tm spacing
    res@gsnMinorLatSpacing    = 1
    res@tmXBLabelFontHeightF  = 0.019         ; change maj lat tm spacing
    res@tmXBMajorLengthF      = 0.02          ; change the tickmark length
    res@tmXBLabelDeltaF       = 1.0
	
	res@mpOutlineOn           = True
    res@mpOutlineBoundarySets = "AllBoundaries"
    ;res@mpAreaNames          = "Brazil"
    res@mpDataBaseVersion     = "MediumRes"   ; necessary for mpDataSetName to be effective
    res@mpLandFillColor       = "bisque2"
    res@mpDataSetName         = "Earth..4"
	res@cnLevelSelectionMode = "ExplicitLevels"
	res@cnLevels    =   (/   0.5  , 1.0, 2.0,3.0,5.0,7.0,  10., 15.,  20.,  25., 30., 35.,40.,45.,50.,60.,75.,80.,90.0,100./)   ; set levels
	res@cnFillOn    = True                        ; turn on color fill
	res@cnLinesOn   = False                       ; turn off the contour lines
	res@cnFillOn    = True                        ; turn on color fill
	res@cnLinesOn   = False                       ; turn off the contour lines
	res@cnLineLabelsOn = False                    ; turn the line labels off
	res@lbBoxLinesOn          = False          ; turn off labelbar box lines
    res@lbOrientation         = "vertical"
    res@lbLabelFontHeightF    = 0.015
    res@cnMaxLevelCount       = 256     
	
	
	res@tiMainString          = config@MainString
    res@gsnRightString        = config@unidade
    res@gsnLeftString         = config@data
    res@gsnStringFontHeightF  = 0.018
    res@tiMainFontHeightF     = 0.02
	
	     plres             = True           ; resource list for polylines
		plres@gsLineColor = "black"
		  plres@gsLineThicknessF = 2.0
		  
	wks = gsn_open_wks("png",config@nomefigura)
    plot = gsn_csm_contour_map(wks, data, res)
	id = gsn_add_shapefile_polylines(wks,plot,shapefile,plres)
draw(plot)
frame(wks)
return(0)
end



;
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
	

	;files_shp=systemfunc("cat "+config@lista_shapes)
	d=dimsizes(files_shp)
	num_shapes=d(0)
	delete(d)
	;
	; tempos
	;
	d=dimsizes(data)
	rank=dimsizes(d)
     print(rank)
	if (rank .eq. 3 )
		;
		;
		;
		print("arquivo de dados tem rank 3")
		num_tempos=d(0)
		M=new((/num_tempos,num_shapes/),"float")
		;
		;
		;
		
		;
		;
		;
		if ( config@tempo_inicial .eq. -1 ) 
			tempo_inicial=0
		else
			tempo_inicial=config@tempo_inicial 
		end if 
		if ( config@tempo_final .eq. -1 ) 
			tempo_final=num_tempos-1
		else
			tempo_final=config@tempo_final 
		end if 
		;
		;
		;
		s0=get_cpu_time()
		s2=s0
		do i=0,num_shapes-1
			s1=get_cpu_time()-s0
			s3=s2-s1
			print(files_shp(i)+" "+s1+"s "+s3+"s ")
			do j=tempo_inicial,tempo_final
				chuva:=calcbacia(data(j,:,:),lat,lon,files_shp(i),config@lon360)
				M(j,i)=chuva@media
			end do
			s2=get_cpu_time()
			
		end do
	elseif (rank .eq. 2) then 
		;
		;
		;
		M=new((/num_shapes/),"float")
		;
		;
		;
		do i=0,num_shapes
			chuva:=calcbacia(data,lat,lon,files_shp(i),config@lon360)
			M(i)=chuva@media
		end do
	elseif (rank .eq. 4) then 
		;
		;
		;
		print("arquivo de dados tem rank 4 - ensembles")
		num_ens=d(0)
		num_tempos=d(1)
		M=new((/num_ens,num_tempos,num_shapes/),"float")
		;
		;
		;
		
		;
		;
		;
		if ( config@tempo_inicial .eq. -1 ) 
			tempo_inicial=0
		else
			tempo_inicial=config@tempo_inicial 
		end if 
		if ( config@tempo_final .eq. -1 ) 
			tempo_final=num_tempos-1
		else
			tempo_final=config@tempo_final 
		end if 
		if (config@ensall) 
			;
			; calcula todos os ensembles 
			;
			s0=get_cpu_time()
			s2=s0
			s4=s0
			do i=0,num_shapes-1
				s1=get_cpu_time()-s0
				s3=s2-s1
				s5=s4-s1
				print(files_shp(i)+" "+s1+"s "+s3+"s "+s5+"s")
				do e=0,num_ens-1
					do j=tempo_inicial,tempo_final
						chuva:=calcbacia(data(e,j,:,:),lat,lon,files_shp(i),config@lon360)
						M(e,j,i)=chuva@media
					end do
					s4=get_cpu_time()
				end do
				s2=get_cpu_time()
			end do
		else 		
			;
			; calcula ensemble especifico 
			;
			print(" trabalhando com enseble"+config@ens)
			s0=get_cpu_time()
			s2=s0
			s4=s0
			do i=0,num_shapes-1
				s1=get_cpu_time()-s0
				s3=s2-s1
				s5=s4-s1
				print(files_shp(i)+" "+s1+"s "+s3+"s "+s5+"s")
				e=config@ens 
					do j=tempo_inicial,tempo_final
						chuva:=calcbacia(data(e,j,:,:),lat,lon,files_shp(i),config@lon360)
						M(e,j,i)=chuva@media
					end do
					s4=get_cpu_time()
					s2=get_cpu_time()
			end do	

		end if 


		
	end if


return(M)
end 







function calcula_chuva_media( fi, config ) 
begin 

	
	;print(fi)
	files_shp=systemfunc("cat "+config@lista_shapes)
	d=dimsizes(files_shp)
	num_shapes=d(0)
	
    if (config@modelo .eq. "CPC") then
		var_list="chuva_cpc"
	 elseif (config@modelo .eq. "GPM") then
		var_list="prec"
	else	
		var_list=getfilevarnames(fi)
		;print(var_list(0))
	end if 

	
	if (config@modelo .eq. "CPC") then 
		print("[SIMOP - CALCBACIA CPC]")
		lat=fi->lat
		lon=fi->lon
		data=fi->chuva_cpc
		tempos=tointeger(cd_calendar(cd_inv_string(fi->date,"%Y%N%D"),0))
		data_str=sprinti("%0.4i",tempos(:,0))+"/"+sprinti("%0.2i",tempos(:,1))+"/"+sprinti("%0.2i",tempos(:,2))+" "+sprinti("%0.4i",tempos(:,0))+" "+sprinti("%0.2i",tempos(:,1))+" "+sprinti("%0.2i",tempos(:,2))+" "+sprinti("%0.2i",tempos(:,3))
		;print(tempos)
	elseif (config@modelo .eq. "GPM") then 
		print("[SIMOP - CALCBACIA GPM]")
		lat=fi->latitude
		lon=fi->longitude
		data=fi->prec
		;print(cd_calendar(fi->time,0))
		tempos=tointeger(cd_calendar(fi->time,0))
		data_str=sprinti("%0.4i",tempos(:,0))+"/"+sprinti("%0.2i",tempos(:,1))+"/"+sprinti("%0.2i",tempos(:,2))+" "+sprinti("%0.4i",tempos(:,0))+" "+sprinti("%0.2i",tempos(:,1))+" "+sprinti("%0.2i",tempos(:,2))+" "+sprinti("%0.2i",tempos(:,3))
		;print(tempos)	
	else
		
		lat=fi->lat_0
		lon=fi->lon_0
		var=fi->$var_list(0)$ 

	
		;
		; obter a matrix de tempo 
		;
		horas=fi->forecast_time0
		;print(horas)
		inicio=var@initial_time
		var2=str_split(inicio,"/")
		var3=str_split(var2(2),"(")
		var4=str_split(var3(1),")")
		units="hours since "+str_squeeze(var3(0))+"-"+var2(0)+"-"+var2(1)+" "+var4(0)+":00"
		horas@units=units
		tempos=tointeger(cd_calendar(horas,0))
		;print(tempos)
		data_str=sprinti("%0.4i",tempos(:,0))+"/"+sprinti("%0.2i",tempos(:,1))+"/"+sprinti("%0.2i",tempos(:,2))+" "+sprinti("%0.4i",tempos(:,0))+" "+sprinti("%0.2i",tempos(:,1))+" "+sprinti("%0.2i",tempos(:,2))+" "+sprinti("%0.2i",tempos(:,3))
		;print(data_str)

	end if
	
	if (var_list(0) .eq. "PRATE_P0_L1_GLL0" ) then  
		;
		; passar de  kg m/s-1 para mm 
		;
		print("[SIMOP - CALCBACIA GFS]")
		data=var*3*3600
		data!0="time"
		data!1="lat"
		data!2="lon"
		data&lat=lat
		data&lon=lon
	elseif (var_list(0) .eq. "APCP_P11_L1_GLL0_acc6h") 
		print("[SIMOP - CALCBACIA GEFS0P25] - ACPC")
		;
		; passar de  kg m/s-1 para mm 
		;
		data=var
		ens=fi->ensemble0+1
		ensname=fi->ensemble0_info
		;print(ensname)
		
		
	elseif ( var_list(0) .eq.  "PRATE_P11_L1_GLL0_avg6h"  ) then 
		;
		; passar de  kg m/s-1 para mm 
		;
		print("[SIMOP - CALCBACIA GEFS0P50] - PRATE")
		data=var*6*3600
		ens=fi->ensemble0+33
		ensname=fi->ensemble0_info
		printVarSummary(data)
		data!0="ens"
		data!1="time"
		data!2="lat"
		data!3="lon"
		data&lat=lat
		data&lon=lon
		data&ens=ens
	end if 
	
	



	config@tempos:=tempos
	
	M=calcula_chuva_media_em_lote( data ,lat ,lon,files_shp, config)
	
	;printVarSummary(M)
	;
	;
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

	if (rank .eq. 2) then 
		num_tempos=d(0)
		if (modelo .eq. "GFS")
			modelo="GFS 00 "+config@datarun
			        
		end if 
		
		do t=0,num_tempos-1
			valores_str:=new((/num_shapes/),"string") 
			do b=0,num_shapes-1
				valores_str(b)=sprintf("%5.2f",M(t,b)) 
			end do 
			linha_valores=str_join(valores_str," ")
			alist=[/modelo,data_str(t),linha_valores/]
			write_table(config@output,"a",alist, "%s %s %s") 
		
		end do	
	elseif (rank .eq. 3 ) then 
	
		
		num_tempos=d(1)
		num_ens=d(0)
		print(" Processando "+num_tempos+" tempos e "+num_ens+" ensembles")
		do t=0,num_tempos-1
			if (config@ensall) 
				do e=0,num_ens-1
					qual_modelo=str_split(modelo,"0") 
					if (qual_modelo(0) .eq. "GEFS") 
						modeloens="GEFS"+" "+sprinti("%02d",ens(e))+" "+config@datarun
					else
						modeloens=modelo+" 99"
					end if
					valores_str:=new((/num_shapes/),"string") 
					do b=0,num_shapes-1
						valores_str(b)=sprintf("%5.2f",M(e,t,b)) 
					end do
					
					linha_valores=str_join(valores_str," ")
					alist=[/modeloens,data_str(t),linha_valores/]
					write_table(config@output,"a",alist, "%s %s %s") 
				end do
			else
				e=config@ens 
				qual_modelo=str_split(modelo,"0") 
				if (qual_modelo(0) .eq. "GEFS") 
						modeloens="GEFS"+" "+sprinti("%02d",ens(e))+" "+config@datarun
				else
						modeloens=modelo+" 99 "
				end if
				valores_str:=new((/num_shapes/),"string") 
				do b=0,num_shapes-1
					valores_str(b)=sprintf("%5.2f",M(e,t,b)) 
				end do
					
				linha_valores=str_join(valores_str," ")
				alist=[/modeloens,data_str(t),linha_valores/]
				write_table(config@output,"a",alist, "%s %s %s") 
			end if 				
		end do	
	end if
	return(0)
end





begin 
   
	
	YYYYMMDD=systemfunc("date +%Y%m%d")
	RODADA="00"
	  config=True
	if (isdefined("lista_shapes") .eq. "False")
		lista_shapes="lista.txt"
	end if 
	
	if (isdefined("modelo") .eq. "False")	
		modelo="GFS"
	end if 
	
	    print(" lista_shapes= "+lista_shapes)
	    print(" modelo         = "+modelo) 
	
	if (isdefined("ensall") .eq. "False")	
		config@ensall=True
		print(" Ensemble     = All")
		print(" Num.Ensembles= 0-30")
	else
		config@ensall=ensall
		if (isdefined("work_ens"))	
			config@ens=work_ens
			print(" Ensemble="+work_ens)
			print(" Num.Ensembles="+work_ens)
		else
			config@ens=0
		end if	

	end if 
	
	
  
	config@lista_shapes=lista_shapes
	config@tempo_inicial=-1
	config@tempo_final=-1
	config@lon360=False
	
	config@output="gfs_saida_"+YYYYMMDD+".csv"
	


	
	
	
	config@append=True          ;;; apendiciona 
	config@datarun=YYYYMMDD+" "+RODADA
	if ( modelo .eq. "GFS")
		config@modelo="GFS"
		
		fi:=addfile("/mnt/d/DADOS/CICC/GRIB/GFS/GFS0P25_"+YYYYMMDD+RODADA+".grib2","r")
		pi:=calcula_chuva_media( fi,config)
	elseif ( modelo .eq. "GEFS0P25") 
		config@modelo="GEFS0P25"	
		fi:=addfile("/mnt/d/DADOS/CICC/GRIB/GEFS/GEFS0P25_"+YYYYMMDD+RODADA+".grib2","r")
		pi:=calcula_chuva_media( fi,config)
	elseif (modelo.eq. "GEFS0P50")  	
			config@modelo="GEFS0P50"
			fi:=addfile("/mnt/d/DADOS/CICC/GRIB/GEFS/GEFS0P50_"+YYYYMMDD+RODADA+".grib2","r")
			pi:=calcula_chuva_media( fi,config)
	end if 

	 
exit

chuva:=calcbacia(data(14,:,:),lat,lon,"Tot_JRB.shp",False)
limite:=chuva@limites_shp
printVarSummary(chuva)

config=True
config@nomefigura="CPC.png"
config@MainString="CHUVA DIARIA CPC-GAUGE 54 KM"
config@unidade="mm/dia"
config@data="30/08/2019"

config@areashape=True
config@maxlat=10
config@minlat=-40
config@maxlon=330
config@minlon=280 
config@centerlon=305
data@limites_shp=chuva@limites_shp
pi=plota_com_shape(data(14,:,:),"Tot_JRB.shp",config)


exit


fi=addfile("/mnt/d/DADOS/OBS/CHUVAOBS/CPC_GAUGE_0P50/NETCDF/DIARIO/CPC_CU_GAUGE_DIARIO_20210315.nc","r")
data:=fi->chuva_cpc(0,:,:)
lat:=fi->lat 
lon:=fi->lon 
chuva:=calcbacia(data,lat,lon,"Tot_JRB.shp",False)
printVarSummary(chuva)
limite:=chuva@limites_shp
printVarSummary(chuva)
config=True
config@areashape=True
config@nomefigura="CPC.png"
config@MainString="CHUVA DIARIA CPC-GAUGE 54 KM"
config@unidade="mm/dia"
config@data="30/08/2019"
pi=plota_com_shape(chuva,"Tot_JRB.shp",config)

exit





exit


fi=addfile("/mnt/d/DADOS/OBS/CHUVAOBS/CPC_GAUGE_0P50/NETCDF/DIARIO/CPC_CU_GAUGE_DIARIO_20210315.nc","r")
data:=fi->chuva_cpc(0,:,:)
lat:=fi->lat 
lon:=fi->lon 
chuva:=calcbacia(data,lat,lon,"Tot_JRB.shp",False)
printVarSummary(chuva)
limite:=chuva@limites_shp
printVarSummary(chuva)
config=True
config@nomefigura="CPC.png"
config@MainString="CHUVA DIARIA CPC-GAUGE 54 KM"
config@unidade="mm/dia"
config@data="30/08/2019"
pi=plota_com_shape(chuva,"Tot_JRB.shp",config)


fi=addfile("/mnt/d/DADOS/OBS/CHUVAOBS/MERGE_CPTEC_DIARIO_GPM_11KM/NETCDF/MERGE_CPTEC_DIARIO_20190830.nc","r")
data:=fi->prec(0,:,:)
lat:=fi->latitude 
lon:=fi->longitude 
chuva:=calcbacia(data,lat,lon,"uru_rs_mpas.shp",True)
printVarSummary(chuva)
limite:=chuva@limites_shp
config=True
config@nomefigura="GPM.png"
config@MainString="CHUVA DIARIA GPM 11 KM"
config@unidade="mm/dia"
config@data="30/08/2019"
pi=plota_com_shape(chuva,"uru_rs_mpas.shp",config)


end




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
	;
	; calcula se teve chuva = chuva_min na bacia
	;
	dsc=where( data_mask .ge. 0 .and. data_mask .le. 0.5, 1,0)
	soma=sum(dsc)
	if (num_pontos_inside .eq. 0 )
		semchuva=-999
	else	
		semchuva=sum(dsc)/tofloat(num_pontos_inside)
	end if
	


	
	
	
	
	if (num_pontos_inside .gt. 0 )
		media = sum(data_mask)/num_pontos_inside
	else
		media=-1
	end if
    data_mask@num_pontos_inside=num_pontos_inside
	data_mask@soma=soma
	data_mask@media=media 
	data_mask@limites_shp=limites_shp
	data_mask@semchuva=semchuva
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
; config@opt_semchuva     
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
     ;print(rank)
	if (rank .eq. 3 )
		;
		;
		;
		;print("arquivo de dados tem rank 3")
		num_tempos=d(0)
		M=new((/num_tempos,num_shapes/),"float")
		N=M;
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
				N(j,i)=chuva@semchuva
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
		;print("arquivo de dados tem rank 4 - ensembles")
		num_ens=d(0)
		num_tempos=d(1)
		M=new((/num_ens,num_tempos,num_shapes/),"float")
		N=M;
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
					N(j,i)=chuva@semchuva
				end do
				s4=get_cpu_time()
			end do
			s2=get_cpu_time()
		end do		
	end if

	if(config@opt_semchuva)
		return(N)
	else
		return(M)
	end if 	
end 







function calcula_chuva_media( fi, config ) 
begin 

	files_shp=systemfunc("cat "+config@lista_shapes)
	d=dimsizes(files_shp)

	num_shapes=d(0)

    if (config@modelo .eq. "CPC") then
		var_list="chuva_cpc"
	 elseif (config@modelo .eq. "GPM") then
		var_list="prec"
	else	
		var_list=getfilevarnames(fi)
		
	end if 

		
	if (config@modelo .eq. "CPC") then 
		lat=fi->lat
		lon=fi->lon
		data=fi->chuva_cpc
		datax=fi->date
		tempos=tointeger(cd_calendar(cd_inv_string(datax,"%Y%N%D"),0))
		data_str=sprinti("%0.4i",tempos(:,0))+"/"+sprinti("%0.2i",tempos(:,1))+"/"+sprinti("%0.2i",tempos(:,2))+" "+sprinti("%0.4i",tempos(:,0))+" "+sprinti("%0.2i",tempos(:,1))+" "+sprinti("%0.2i",tempos(:,2))+" "+sprinti("%0.2i",tempos(:,3))
	elseif (config@modelo .eq. "GPM") then 
		lat=fi->latitude
		lon=fi->longitude
		data=fi->prec
		print(cd_calendar(fi->time,0))
		tempos=tointeger(cd_calendar(fi->time,0))
		data_str=sprinti("%0.4i",tempos(:,0))+"/"+sprinti("%0.2i",tempos(:,1))+"/"+sprinti("%0.2i",tempos(:,2))+" "+sprinti("%0.4i",tempos(:,0))+" "+sprinti("%0.2i",tempos(:,1))+" "+sprinti("%0.2i",tempos(:,2))+" "+sprinti("%0.2i",tempos(:,3))
	else	
		lat=fi->lat_0
		lon=fi->lon_0
		var=fi->$var_list(0)$ 

	
		;
		; obter a matrix de tempo 
		;
		horas=fi->forecast_time0
		print(horas)
		inicio=var@initial_time
		var2=str_split(inicio,"/")
		var3=str_split(var2(2),"(")
		var4=str_split(var3(1),")")
		units="hours since "+str_squeeze(var3(0))+"-"+var2(0)+"-"+var2(1)+" "+var4(0)+":00"
		horas@units=units
		tempos=tointeger(cd_calendar(horas,0))
		data_str=sprinti("%0.4i",tempos(:,0))+"/"+sprinti("%0.2i",tempos(:,1))+"/"+sprinti("%0.2i",tempos(:,2))+" "+sprinti("%0.4i",tempos(:,0))+" "+sprinti("%0.2i",tempos(:,1))+" "+sprinti("%0.2i",tempos(:,2))+" "+sprinti("%0.2i",tempos(:,3))
	end if


	config@tempos:=tempos;
	M=calcula_chuva_media_em_lote( data ,lat ,lon,files_shp, config)
		
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
			do e=0,num_ens-1
				qual_modelo=str_split(modelo,"0") 
				if (qual_modelo(0) .eq. "GEFS") 
					modeloens=modelo+sprinti("%02d",e)
				else
					modeloens=modelo
				end if
				valores_str:=new((/num_shapes/),"string") 
				do b=0,num_shapes-1
					valores_str(b)=sprintf("%5.2f",M(e,t,b)) 
				end do
				
			linha_valores=str_join(valores_str," ")
			alist=[/modeloens,data_str(t),linha_valores/]
			write_table(config@output,"a",alist, "%s %s %s") 
			end do	
		end do	
	end if
		
	return(0)
end




begin 
	
	
	if(.not.isdefined("ano_inicial")) 
		ano_inicial=1979
	end if 
	if(.not.isdefined("ano_final")) 
		ano_final=2021
	end if 
	print(" Calculando a partir do ano "+ano_inicial+" ate o ano de "+ano_final)

	
	shapes="SAE_shp.dat"
	
	;
	;  CPC
	;
	config=True
	config@lista_shapes="/mnt/e/OPERACIONAL/SIMOP/CONTORNOS/"+shapes
	config@tempo_inicial=-1
	config@tempo_final=-1
	config@lon360=False
	config@modelo="CPC"
	config@output="climacpc_chuva_SAE.csv"
	config@append=True
	config@opt_semchuva=False
	
	do ano=ano_inicial,ano_final
		ano_char=sprinti("%04d",ano)
		files:=systemfunc("ls -1 /mnt/d/DADOS/OBS/CHUVAOBS/CPC_GAUGE_0P50/NETCDF/DIARIO/CPC_CU_GAUGE_DIARIO_"+ano_char+"*.nc ")	
		d:=dimsizes(files)
		num_files=d(0)
		fi:=addfile(files(0),"r")	

		pi:=calcula_chuva_media( fi,config)
		config@append=True
		do i=1,num_files-1
			fi=addfile(files(i),"r")	
			pi:=calcula_chuva_media( fi,config)
		end do
	end do 
end 	
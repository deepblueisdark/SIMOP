load "$NCARG_ROOT/lib/ncarg/nclscripts/contrib/cd_inv_string.ncl"
begin
	
	;---Open shapefile and read Mississippi River Basin lat/lon values.
	dir     = "/mnt/d/DADOS/SHAPES/OPERACIONAL/"
	filename= dir + "sinv1.shp"
	f       = addfile(dir + "sinv1.shp", "r")
	mrb_lon = f->x+360
	mrb_lat = f->y
	nmrb    = dimsizes(mrb_lon)
	;
	; listagem dos arquivos em netcdf
	;
	files=systemfunc("ls -1 /mnt/d/DADOS/OBS/CHUVAOBS/MERGE_CPTEC_HORARIO_GPM_11KM/NETCDF/MERGE_CPTEC_2021*.nc | tail -720") 
	fi=addfiles(files,"r")
	;
	; abre as variaveis
	;	
 	chuva=fi[:]->prec
	lat=chuva&latitude
	lon=chuva&longitude
	;
	; diemnsoes
	;
	d=dimsizes(chuva)
	num_tempos=d(0)
	;
	; cria vetor de datas
	;
	var=chuva@initial_time
	tempos=chuva&time
	print(" Existem "+num_tempos+" dias a serem processados") 
	datas = floattointeger(cd_calendar(tempos, 0))   
	data_ano=tostring_with_format(datas(:,0), "%04d")
	data_mes=tostring_with_format(datas(:,1), "%02d")
	data_dia=tostring_with_format(datas(:,2), "%02d")
	data_hora=tostring_with_format(datas(:,3), "%02d")
	datas_str=data_dia+"/"+data_mes+"/"+data_ano+" : "+data_hora+"Z"
    print(datas_str)
	;
	; para uso das funcoes estatisticas
	; para chuva de T L L para chuva L L T
	; 
    chuvaLLT=chuva(latitude|:,longitude|:,time|:)
	;
	;  calcula chuva ultimas 24 horas
	;
	ind_24h_start=num_tempos-24
	ind_24h_end=num_tempos-1
	chuva_ultimas_24horas=dim_sum_n_Wrap(chuvaLLT(:,:,ind_24h_start:ind_24h_end),2) 
    ;
	;
	;
	;
	;  calcula chuva ultimas 7 dias
	;
	ind_7d_start=num_tempos-(24*7)
	ind_7d_end=num_tempos-1
	chuva_ultimos_7d=dim_sum_n_Wrap(chuvaLLT(:,:,ind_7d_start:ind_7d_end),2) 
    ;
	;
	;
	;
	;
	;  calcula chuva ultimas 15 dias
	;
	ind_15d_start=num_tempos-(24*15)
	ind_15d_end=num_tempos-1
	chuva_ultimos_15d=dim_sum_n_Wrap(chuvaLLT(:,:,ind_15d_start:ind_15d_end),2) 
    ;
	;
	;
	;
	;
	;  calcula chuva ultimas 30 dias
	;
	ind_30d_start=num_tempos-(24*30)
	ind_30d_end=num_tempos-1
	print(num_tempos+" "+ind_30d_start+" "+ind_30d_end) 
	chuva_ultimos_30d=dim_sum_n_Wrap(chuvaLLT(:,:,ind_30d_start:ind_30d_end),2) 
    ;
	;
	;
 
 


		;  estruttura do mapa 
		;
		res							= True
		  res@gsnDraw             = False          ; don't draw plot yet
  res@gsnFrame            = False          ; don't advance frame yet
		;
		;  limites do mapa 
		;		
		res@gsnAddCyclic          = False
		res@mpMinLatF			  =-40
		res@mpMaxLatF             = 10
		res@mpMinLonF             = -80
		res@mpMaxLonF             = -30
		res@mpLimitMode           ="latlon"
		res@gsnMaximize           = True              ; Maximize plot
 		res@cnFillOn              = True              ; color plot desired
		res@cnFillMode            = "RasterFill"      ; USES LESS MEMORY AND IS FASTER
		res@cnFillPalette         = "wh-bl-gr-ye-re"
		res@cnLinesOn             = False             ; turn off contour lines
		res@cnLineLabelsOn        = False    
		res@cnFillOn    = True                        ; turn on color fill
		res@cnLinesOn   = False                       ; turn off the contour lines
		res@cnFillOn    = True                        ; turn on color fill
		res@cnLinesOn   = False                       ; turn off the contour lines
		res@cnLineLabelsOn = False                    ; turn the line labels off
		res@lbBoxLinesOn          = False          ; turn off labelbar box lines
		res@lbOrientation         = "vertical"
		res@lbLabelFontHeightF    = 0.015
		res@cnMaxLevelCount       = 256     
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
		;---Resources for polyline
	lnres                  = True
  lnres@gsLineColor      = "black"
  lnres@gsLineThicknessF = 4.0            ; 2x thickness
lres=lnres 
		figura="CHUVA_GPM_ULTIMAS24HORAS.png"
		res@cnLevelSelectionMode = "ExplicitLevels"   ; set explicit contour levels

;		res@cnLevels    =  (/ 0.1,  0.5 , 1.0, 2.0 ,3.0 ,4.0 ,5.0, 6.0 ,7.0 ,8.0 ,9.0 , 10.0 ,12.,15.00, 17.00, 20.00, 23.00,25.00,30.00/)   ; set levels
res@cnLevels    :=   (/   0.5  , 5.0,  10., 15.,  20.,  25., 30., 35.,40.,45.,50.,60.,75.,80.,90.0,100.,120.,150.,180.,200.,250.00,300.0/)   
	res@tiMainString          = " CHUVA HORARIA 11 KM GPM - ULTIMAS 24 HORAS "
		res@gsnRightString        = "mm/dia"
		res@gsnLeftString         = datas_str(ind_24h_start)+" a "+datas_str(ind_24h_end)
		res@gsnStringFontHeightF  = 0.018
		res@tiMainFontHeightF     = 0.02
		wks = gsn_open_wks("png",figura)
		plot = gsn_csm_contour_map(wks, chuva_ultimas_24horas(:,:), res)
		;mrb_line_map   = gsn_add_polylines(wks,plot,mrb_lon,mrb_lat,lnres)
		shap= gsn_add_shapefile_polylines(wks,plot,filename,lres)
		draw(plot)
		frame(wks)
		
		
		figura="CHUVA_GPM_ULTIMOS7DIAS.png"
		res@cnLevelSelectionMode = "ExplicitLevels"   ; set explicit contour levels
		
		res@cnLevels    :=   (/   0.5  , 5.0,  10., 15.,  20.,  25., 30., 35.,40.,45.,50.,60.,75.,80.,90.0,100.,120.,150.,180.,200.,250.00,300.0/)   ; set levels
		res@tiMainString          = " CHUVA HORARIA 11 KM GPM - ULTIMOS 7 DIAS "
		res@gsnRightString        = "mm/dia"
		res@gsnLeftString         = datas_str(ind_7d_start)+" a "+datas_str(ind_7d_end)
		res@gsnStringFontHeightF  = 0.018
		res@tiMainFontHeightF     = 0.02
		wks = gsn_open_wks("png",figura)
		plot = gsn_csm_contour_map(wks, chuva_ultimos_7d(:,:), res)
			;mrb_line_map   = gsn_add_polylines(wks,plot,mrb_lon,mrb_lat,lnres)
			shap= gsn_add_shapefile_polylines(wks,plot,filename,lres)
		draw(plot)
		frame(wks)
		
		figura="CHUVA_GPM_ULTIMOS15DIAS.png"
		res@cnLevelSelectionMode = "ExplicitLevels"   ; set explicit contour levels
		
		;res@cnLevels    :=   (/   0.5  , 5.0,  10., 15.,  20.,  25., 30., 35.,40.,45.,50.,60.,75.,80.,90.0,100.,120.,150.,180.,200.,250.00,300.0,400.00,500.00/)   ; set levels
		res@tiMainString          = " CHUVA HORARIA 11 KM GPM - ULTIMOS 15 DIAS "
		res@gsnRightString        = "mm/dia"
		res@gsnLeftString         = datas_str(ind_15d_start)+" a "+datas_str(ind_15d_end)
		res@gsnStringFontHeightF  = 0.018
		res@tiMainFontHeightF     = 0.02
		wks = gsn_open_wks("png",figura)
		plot = gsn_csm_contour_map(wks, chuva_ultimos_15d(:,:), res)
			;mrb_line_map   = gsn_add_polylines(wks,plot,mrb_lon,mrb_lat,lnres)
			shap= gsn_add_shapefile_polylines(wks,plot,filename,lres)
		draw(plot)
		frame(wks)
 
 	figura="CHUVA_GPM_ULTIMOS30DIAS.png"
 		;res@cnLevels    :=   (/   0.5  , 10.,50.,100.,150.,200.,300.0,400.00, 500.00,750,1000/)   ; set levels
		res@tiMainString          = " CHUVA HORARIA 11 KM GPM - ULTIMOS 30 DIAS "
		res@gsnRightString        = "mm/dia"
		res@gsnLeftString         = datas_str(ind_30d_start)+" a "+datas_str(ind_30d_end)
		res@gsnStringFontHeightF  = 0.018
		res@tiMainFontHeightF     = 0.02
		wks = gsn_open_wks("png",figura)
		plot = gsn_csm_contour_map(wks, chuva_ultimos_30d(:,:), res)
			;mrb_line_map   = gsn_add_polylines(wks,plot,mrb_lon,mrb_lat,lnres)
			shap= gsn_add_shapefile_polylines(wks,plot,filename,lres)
		draw(plot)
		frame(wks)
 end 
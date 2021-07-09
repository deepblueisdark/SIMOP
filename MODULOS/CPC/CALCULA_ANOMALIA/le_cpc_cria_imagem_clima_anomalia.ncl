load "$NCARG_ROOT/lib/ncarg/nclscripts/esmf/ESMF_regridding.ncl"


function plota_climatologia(fi,config)
begin 



		tempos=((/"Janeiro","Fevereiro","Marco","Abril", \
		"Maio","Junho","Julho","Agosto","Setembro",\
		"Outubro","Novembro","Dezembro"/)) 
		fator=((/31,28,31,30,31,30,31,31,30,31,30,31/)) 
	chuva=fi->chuva
	lat=fi->lat
	lon=fi->lon
	lev=0

	dirESMF="/mnt/e/OPERACIONAL/SIMOP/MODULOS/CPC/CALCULA_ANOMALIA/"
	dir     = "/mnt/d/DADOS/SHAPES/OPERACIONAL/"
	filename = dir + "sinv1.shp"

	

    Opt                = True

	Opt@SrcFileName    = dirESMF+"src_SCRIP.nc"
    Opt@DstFileName    = dirESMF+"dst_SCRIP.nc"
    Opt@WgtFileName    = dirESMF+"NCEP_2_Rect.nc"
    Opt@ForceOverwrite = True
    Opt@DstGridType    = "0.25x0.25"
    Opt@DstLLCorner    = (/ -89.75,   0.25/)
    Opt@DstURCorner    = (/  89.75, 359.75/)
	
	do mes=0,11
		chuva_mes=chuva(:,:,mes)*fator(mes)
		copy_VarAtts(chuva, chuva_mes)                    
		copy_VarCoords_1(chuva,chuva_mes)
		printVarSummary(chuva_mes)
		;Opt@SrcGridMask    = where(.not.ismissing(chuva_mes(:,:)),1,0)   ; use SrcMask2D in NCL V6.2.1 and earlier
		Opt@SrcMask2D    = where(.not.ismissing(chuva_mes(:,:)),1,0)	


		temp_regrid = ESMF_regrid(chuva_mes(:,:),Opt)
    
		
		figura=config@nome_figura+tempos(mes)+".png"
		print(figura)
		wks = gsn_open_wks("png",figura)
		res                       = True 
		res@gsnDraw             = False          ; don't draw plot yet
		res@gsnFrame            = False   
		res@gsnAddCyclic          = False
		res@mpMinLatF			  =	-40
		res@mpMaxLatF             =	10
		res@mpMinLonF             =	-80
		res@mpMaxLonF             = -30
		res@mpLimitMode           ="latlon"
		res@gsnMaximize           = True              ; Maximize plot
		res@cnFillOn              = True              ; color plot desired
		res@cnFillMode            = "RasterFill"      ; USES LESS MEMORY AND IS FASTER
		;res@cnFillPalette         = "BlAqGrWh2YeOrReVi22"
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
		;res@cnLevelSelectionMode = "ExplicitLevels"
		gsn_define_colormap(wks,"MPL_jet")
		gsn_reverse_colormap(wks)
		res@cnLevelSelectionMode="ManualLevels"
		res@cnLevelSpacingF=10
		res@cnMinLevelValF=10
		res@cnMaxLevelValF=300
		;res@cnLevels    =   (/10,20,30,40,50,60,70,80,90,100,110,120,130,140,150,160,170,180,190,200,210,220,230,240,250,260,270,280,290,300,350,400,450,500/)
		
		res@cnFillOn    = True                        ; turn on color fill
		res@cnLinesOn   = False                       ; turn off the contour lines
		res@cnFillOn    = True                        ; turn on color fill
		res@cnLinesOn   = False                       ; turn off the contour lines
		res@cnLineLabelsOn = False                    ; turn the line labels off
		res@lbBoxLinesOn          = False          ; turn off labelbar box lines
		res@lbOrientation         = "vertical"
		res@lbLabelFontHeightF    = 0.015
		res@cnMaxLevelCount       = 256     
		
		
		res@tiMainString          = config@titulo_principal
		res@gsnRightString        = "mm/dia"
		res@gsnLeftString         = tempos(mes)
		res@gsnStringFontHeightF  = 0.018
		res@tiMainFontHeightF     = 0.02
		
		
		
		lnres                  = True
		lnres@gsLineColor      = "black"
		lnres@gsLineThicknessF = 4.0            ; 2x thickness
		lres=lnres 
		plot = gsn_csm_contour_map(wks, temp_regrid(:,:), res)
		shap= gsn_add_shapefile_polylines(wks,plot,filename,lres)
		draw(plot)
		frame(wks)
		end do 
	 return(0)
	
end



function plota_climatologia_anomalia(fi,gi,config)
begin 


dir     = "/mnt/d/DADOS/SHAPES/OPERACIONAL/"
	filename = dir + "sinv1.shp"
	
	chuvax=gi[:]->chuva_cpc 
	chuva_atual=chuvax(lat|:,lon|:,time|:) 
	printVarSummary(chuva_atual)
	chuva_media_atual=dim_avg_n_Wrap(chuva_atual,2)
	delete(chuvax)
	delete(chuva_atual)


fator=((/31,28,31,30,31,30,31,31,30,31,30,31/)) 



	tempos=((/"Janeiro","Fevereiro","Marco","Abril", \
		"Maio","Junho","Julho","Agosto","Setembro",\
		"Outubro","Novembro","Dezembro"/)) 
	chuva=fi->chuva
	lat=fi->lat
	lon=fi->lon
	lev=0




	

    Opt                = True

	Opt@SrcFileName    = "src_SCRIP.nc"
    Opt@DstFileName    = "dst_SCRIP.nc"
    Opt@WgtFileName    = "NCEP_2_Rect.nc"
    Opt@ForceOverwrite = True
    Opt@DstGridType    = "0.25x0.25"
    Opt@DstLLCorner    = (/ -89.75,   0.25/)
    Opt@DstURCorner    = (/  89.75, 359.75/)
	
	if ( config@escalamm .eq. "dia" )
		chuva_mes=(chuva_media_atual-chuva(:,:,config@mes))
		copy_VarAtts(chuva, chuva_mes)                    
		copy_VarCoords_1(chuva,chuva_mes)
		printVarSummary(chuva_mes)
	else
		chuva_mes=((chuva_media_atual*fator(config@mes))-(chuva(:,:,config@mes)*fator(config@mes)))
		copy_VarAtts(chuva, chuva_mes)                    
		copy_VarCoords_1(chuva,chuva_mes)
		printVarSummary(chuva_mes)
end if 	
		
		;Opt@SrcGridMask    = where(.not.ismissing(chuva_mes(:,:)),1,0)   ; use SrcMask2D in NCL V6.2.1 and earlier
		Opt@SrcMask2D    = where(.not.ismissing(chuva_mes(:,:)),1,0)	


		temp_regrid = ESMF_regrid(chuva_mes(:,:),Opt)
    
		
		figura=config@nome_figura+tempos(config@mes)+".png"
		print(figura)
		wks = gsn_open_wks("png",figura)
		res                       = True 
				  res@gsnDraw             = False          ; don't draw plot yet
  res@gsnFrame            = False   
		res@gsnAddCyclic          = False
		res@mpMinLatF			  =	-40
		res@mpMaxLatF             =	10
		res@mpMinLonF             =	-80
		res@mpMaxLonF             = -30
		res@mpLimitMode           ="latlon"
		res@gsnMaximize           = True              ; Maximize plot
		res@cnFillOn              = True              ; color plot desired
		res@cnFillMode            = "RasterFill"      ; USES LESS MEMORY AND IS FASTER
		;res@cnFillPalette         = "BlAqGrWh2YeOrReVi22"
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
		gsn_define_colormap(wks,"escala_cores_cptec") ;;"BlAqGrWh2YeOrReVi22")
		;gsn_reverse_colormap(wks)
		;gsn_draw_colormap(wks) 
		
		;res@cnLevels    =   (/   0.5  , 1.0, 2.0,3.0,5.0,7.0,  10., 15.,  20.,  25., 30., 35.,40.,45.,50.,60.,75.,80.,90.0,100./)   ; set levels
		;res@cnLevels    =   (/  1,5,10,20,30,40,50,60,70,80,90,100,110,120,130,140,150,160,170,180,190,200,210,220,230,240,250,260,270,280,290,300,350,400,450,500/)
	
		
		
		if (config@escalamm .eq. "dia")
		      
			  res@cnLevels    = (/ -12, -10.,-8.,-6.,-5,-4.,-3,-2.,-1.,0,1.,2.,3,4.,5, 6.,8.,10.,12./) 
		else
		    res@cnFillColors = (/   9,    8,   6, 4 ,  3, 2,21, 22,23,28,29,38 /)  ; set the colors to be used
			res@cnLevels     = (/-300, -200,-100,-50,-25,0,25,50,100,200,300/) 
		end if 
		
		res@cnFillOn    = True                        ; turn on color fill
		res@cnLinesOn   = False                       ; turn off the contour lines
		res@cnFillOn    = True                        ; turn on color fill
		res@cnLinesOn   = False                       ; turn off the contour lines
		res@cnLineLabelsOn = False                    ; turn the line labels off
		res@lbBoxLinesOn          = False          ; turn off labelbar box lines
		res@lbOrientation         = "vertical"
		res@lbLabelFontHeightF    = 0.015
		res@cnMaxLevelCount       = 256     
		
		
		res@tiMainString          = config@titulo_principal
		res@gsnRightString        = "mm/dia"
		res@gsnLeftString         = tempos(config@mes)
		res@gsnStringFontHeightF  = 0.018
		res@tiMainFontHeightF     = 0.02
		
		lnres                  = True
		lnres@gsLineColor      = "black"
		lnres@gsLineThicknessF = 4.0            ; 2x thickness
		lres=lnres 
		
		plot = gsn_csm_contour_map(wks, temp_regrid(:,:), res)
		shap= gsn_add_shapefile_polylines(wks,plot,filename,lres)
			draw(plot)
		frame(wks)
	 return(0)
	
end
	
begin 
	;
    ;
	; 
	path=systemfunc("echo $PATH")
	print(path)
	;
	;
	; pega a data do dia 
	;
	YYYYMM=systemfunc("date +%Y%m")
	MM=systemfunc("date +%m")
	;
	;
	;
	config=True
	;dir_clima="../../MODULOS/CPC/CLIMA/CLIMATOLOGIAS/"
	dir_clima="/mnt/d/DADOS/OBS/CHUVAOBS/CPC_GAUGE_0P50/CLIMATOLOGIA/"
	
	if (isdefined("modo_run") .eq. "False") then 
		;
		;
		;  config geral 
		;
		
		
		if (isdefined("data_run") .eq. "False") then  
			print("data_run='YYYYMMDD' não foi definido")
			data_run=YYYYMM
         end if
		if (isdefined("mes_run") .eq. "False") then  
			print("Mes da anomalia não definido") 
			mes_run=tointeger(MM)-1
		end if
		print(data_run+" "+mes_run)
		;
		;  1981a 2010
		;
		base="1981A2010"
		fi:=addfile(dir_clima+base+"/"+"CPC_climatology_"+base+".nc","r")
		files:=systemfunc("ls -1 /mnt/d/DADOS/OBS/CHUVAOBS/CPC_GAUGE_0P50/NETCDF/DIARIO/CPC_CU_GAUGE_DIARIO_"+data_run+"*") 
		gi=addfiles(files,"r")
		config=True
		config@escalamm="mes"
		config@titulo_principal=" ANOMALIA DE CHUVA CPC-54KM - CLIMATOLOGIA:"+base
		config@nome_figura="CPC_0P25_C"+base+"_ANOMALIA_"
		config@mes=mes_run
		pi=plota_climatologia_anomalia(fi,gi,config)
		
		
		base="1991A2020"
		fi:=addfile(dir_clima+base+"/"+"CPC_climatology_"+base+".nc","r")
		files:=systemfunc("ls -1 /mnt/d/DADOS/OBS/CHUVAOBS/CPC_GAUGE_0P50/NETCDF/DIARIO/CPC_CU_GAUGE_DIARIO_"+data_run+"*") 
		gi=addfiles(files,"r")
		config=True
		config@escalamm="mes"
		config@titulo_principal=" ANOMALIA DE CHUVA CPC-54KM - CLIMATOLOGIA:"+base
		config@nome_figura="CPC_0P25_C"+base+"_ANOMALIA_"
		config@mes=mes_run
		pi=plota_climatologia_anomalia(fi,gi,config)

		base="2011A2020"
		fi:=addfile(dir_clima+base+"/"+"CPC_climatology_"+base+".nc","r")
		files:=systemfunc("ls -1 /mnt/d/DADOS/OBS/CHUVAOBS/CPC_GAUGE_0P50/NETCDF/DIARIO/CPC_CU_GAUGE_DIARIO_"+data_run+"*") 
		gi=addfiles(files,"r")
		config=True
		config@escalamm="mes"
		config@titulo_principal=" ANOMALIA DE CHUVA CPC-54KM - CLIMATOLOGIA:"+base
		config@nome_figura="CPC_0P25_C"+base+"_ANOMALIA_"
		config@mes=mes_run
		pi=plota_climatologia_anomalia(fi,gi,config)

		return 
	else
	   
		;Base="2011A2020"
		;fi:=addfile(dir_clima+base+"/"+"CPC_climatology_"+base+".nc","r")
		;config@titulo_principal=" ANOMALIA DE CHUVA CPC-54KM - CLIMATOLOGIA:2011A2020"
		;config@nome_figura="CPC_0P25_C2011A2020_CLIMATOLOGIA_"
		;pi=plota_climatologia(fi,config)

		base="1981A2010"
		fi:=addfile(dir_clima+base+"/"+"CPC_climatology_"+base+".nc","r")
		config@titulo_principal=" ANOMALIA DE CHUVA CPC-54KM - CLIMATOLOGIA:1981A2010"
		config@nome_figura="CPC_0P25_C1981A2010_CLIMATOLOGIA_"
		pi=plota_climatologia(fi,config)



		base="1991A2020"
		fi:=addfile(dir_clima+base+"/"+"CPC_climatology_"+base+".nc","r")
	    config@titulo_principal=" ANOMALIA DE CHUVA CPC-54KM - CLIMATOLOGIA:1991A2020"
		config@nome_figura="CPC_0P25_C1991A2020_CLIMATOLOGIA_"
		pi=plota_climatologia(fi,config)



	end if 

	
	
	
	
end
	

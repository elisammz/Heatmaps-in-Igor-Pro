

//call the ext or ret folder e.g. "Separate_F_D_Ext"
//always change in preheatmaps too!
//new_folder is the folder with the calculated heatmaps with the suffix"_Hist"

Function heatmaps(new_folder)
	String new_folder
	string thewave,wave_name, myHiststr, thewave2, wave_name2, thewave3, wave_name3
	variable i, j, y_min, y_max, x_min, x_max
	
	
	//kill_data_points("Separate_F_D_Ret", "OffsetAxis_Hist_Ret") 	//ALWAYS MODIFY HERE, it removes the first 3 columns and it only leaves force and sepa columns
	
	
	Pre_heatmp("Ret_folder", "no_outliers", -0.2e-9, 6e-9) //define max and min values to find outliers
	 
	Folder_Maker(new_folder)
	 
 	DFREF path = GetDataFolderDFR()	//path = root
 	
 	cd new_folder
	DFREF new_path = GetDataFolderDFR() //new_path is heatmaps
	
	cd path
	
	Separate_Force( new_folder, "no_outliers")
		 
	cd root:no_outliers
	
	//creates the histograms in new_folder
	i = 0
	j = 0
	
	thewave = wavelist ("*",";","")
	
	Do 
	
		wave_name = stringfromlist (i, thewave)
		
		if (strlen (wave_name) == 0)
			break	
		endif			
		
		cd new_path
		make/o/n = (65,20) myHist		
		
		cd path
		cd new_folder
	
	//in new_folder, finds the min and max values to set axis scales for heatmaps
	
		thewave2 = wavelist ("*Force",";","")
		thewave3 = wavelist ("*Sep",";","")
		 
		wave_name2 = stringfromlist (j, thewave2)
		wave_name3 = stringfromlist (j, thewave3)
		
		Duplicate/O $wave_name2, newwave2		
		
		y_min = WaveMin(newwave2)
		y_max = WaveMax(newwave2)
			
		print "y-scale: ", y_min, y_max
					
		Duplicate/O $wave_name3, newwave3	
		
		x_min = WaveMin(newwave3)
		x_max = WaveMax(newwave3)		
			
		print "x-scale: ", x_min, x_max
	
		setscale y, 0, 350e-12, myHist //ADJUST FORCE LIMIT AS REQUIRED
		setscale x, -2e-10, 6.4e-9, myHist
		
		JointHistogram(newwave3, newwave2, myHist)
		
		myHiststr = wave_name + "_Hist"
		
		Duplicate/O myHist, new_path:$myHiststr
		
		print wave_name
		
		plot_htmp(new_path:$myHiststr,wave_name)
					
		killwaves myHist, newwave2, newwave3
		
		i += 1
		j += 1
		
	while(1)	
	 	
	cd path	 
End




Function Insert_textbox (wave_name)
	string wave_name
	TextBox/C/N=text1 "\\Z18\\f01"+ wave_name + "_Ret" //ALWAYS MODIFY HERE IF NEEDED
End



Function plot_htmp (data, wave_name) //also saves the heatmap
	wave data
	string wave_name
	string myHiststr=""
	
	newimage data
	SetAxis/A left
	ModifyGraph width=360,height=360
	ModifyImage $myHiststr ctab= {50,*,YellowHot,0}
	ModifyGraph margin(left)=60,margin(bottom)=60,margin(top)=60,margin(right)=75
	ModifyGraph lblMargin(top)=20;DelayUpdate
	Label top "\\Z16\\f01\\u#2Separation (nm)"
	ModifyGraph nticks(top)=10,minor(top)=0
	ModifyGraph fStyle(top)=1,fSize(top)=12
	ModifyGraph lblMargin(left)=20;DelayUpdate
	Label left "\\Z16\\f01\\u#2Force (pN)"
	ModifyGraph fStyle(left)=1,fSize(left)=12
	ModifyGraph nticks(left)=10,minor(left)=0
	ColorScale/C/N=text0/A=MC image=$myHiststr,nticks=3
	ColorScale/C/N=text0/A=RC/X=-18.33/Y=5.21 image=$myHiststr
	ModifyGraph mirror(top)=3
	
	Insert_textbox (wave_name) 
	
	SavePICT/E=-6/B=288/I/W=(0,0,6,6) as wave_name
End

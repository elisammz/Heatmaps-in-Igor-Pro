//returns a 2D histogram
//hist is the wave with the number of columns and rows for the 2d histogram
//hist has to be a pre-existent wave in the same folder
//w0 is the wave for the x-axis, rows, usually separation
//w1 is the wave in y-axis, columns, usually force
Function JointHistogram(w0,w1,hist)
    wave w0,w1,hist
   
    variable bins0=dimsize(hist,0)
    variable bins1=dimsize(hist,1)
    variable n=numpnts(w0)
    variable left0=dimoffset(hist,0)
    variable left1=dimoffset(hist,1)
    variable right0=left0+bins0*dimdelta(hist,0)
    variable right1=left1+bins1*dimdelta(hist,1)
   
    // Scale between 0 and the number of bins to create an index wave.  
    if(ThreadProcessorCount<4) // For older machines, matrixop is faster.  
        matrixop /free idx=floor(bins0*(w0-left0)/(right0-left0))+bins0*floor(bins1*(w1-left1)/(right1-left1))
    else // For newer machines with many cores, multithreading with make is faster.  
        make /free/n=(n) idx
        multithread idx=floor(bins0*(w0-left0)/(right0-left0))+bins0*floor(bins1*(w1-left1)/(right1-left1))
    endif
    
   print left0
   print left1
   print right0
   print right1
   
    // Compute the histogram and redimension it.  
    histogram /b={0,1,bins0*bins1} idx,hist
    redimension /n=(bins0,bins1) hist // Redimension to 2D.  
    setscale x,left0,right0,hist // Fix the histogram scaling in the x-dimension.  
    setscale y,left1,right1,hist // Fix the histogram scaling in the y-dimension.  
End
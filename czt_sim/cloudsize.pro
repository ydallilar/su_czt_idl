;solves diffusion problem as sigma of the gaussian distribution with respect to time
PRO cloudsize,sigma,time,T=vT,edep=vedep,mob=vmob,isigma=visigma,bg=vbg,eps=veps,itime=vitime,ftime=vftime,int=vint,withrep=withrep,plot=plot

  ;optional inputs
  IF NOT keyword_set(vT) THEN vT=298
  IF NOT keyword_set(vedep) THEN vedep=3000
  IF NOT keyword_set(vmob) THEN vmob=0.1
  IF NOT keyword_set(visigma) THEN visigma=1e-6
  IF NOT keyword_set(vbg) THEN vbg=2
  IF NOT keyword_set(veps) THEN veps=12
  IF NOT keyword_set(vitime) THEN vitime=0
  IF NOT keyword_set(vftime) THEN vftime=4e-7
  IF NOT keyword_set(vint) THEN vint=1e-9
  ;physical constants
  kb=1.3806488e-23
  e=1.602176565e-19
  eps0=8.8542e-12
  
  ;calculation of diffusion and repulsion coefficients
  coef1=(vmob*kb*vT)/e
  coef2=(vmob*e*vedep)/(vbg*24.*(!PI^1.5)*eps0*veps)

  steps = floor((vftime-vitime)/vint)
  tsigma = dblarr(2,steps+1)
  tsigma[*,0] = visigma

;runge-kutta for diffusion
  FOR i=1,steps DO BEGIN
     k1=vint*coef1/tsigma[0,i-1]
     k2=vint*coef1/(tsigma[0,i-1]+k1/2)
     k3=vint*coef1/(tsigma[0,i-1]+k2/2)
     k4=vint*coef1/(tsigma[0,i-1]+k3)
     tsigma[0,i]=tsigma[0,i-1]+(k1+k2*2+k3*2+k4)/6
  ENDFOR
  sigma=reform(tsigma[0,*])

;runge-kutta for diffusion and repulsion
IF keyword_set(withrep) THEN BEGIN
  FOR i=1,steps DO BEGIN
     k1=vint*coef1/tsigma[1,i-1]+vint*coef2/(tsigma[1,i-1]^2)
     k2=vint*coef1/(tsigma[1,i-1]+k1/2)+vint*coef2/((tsigma[1,i-1]+k1/2)^2)
     k3=vint*coef1/(tsigma[1,i-1]+k2/2)+vint*coef2/((tsigma[1,i-1]+k2/2)^2)
     k4=vint*coef1/(tsigma[1,i-1]+k3)+vint*coef2/((tsigma[1,i-1]+k3)^2)
     tsigma[1,i]=tsigma[1,i-1]+(k1+k2*2+k3*2+k4)/6
  ENDFOR
  sigma=reform(tsigma[1,*])
ENDIF

;plotting
IF keyword_set(plot) THEN BEGIN
   plot,sigma[0,*]
   IF keyword_set(withrep) THEN oplot,sigma[1,*],linestyle=2
ENDIF

END

;*******************************************************************************
;creates photons on the source shoots them over the mask and holds
;placement data on the detector for the ones who passes the mask
;------------------------------------------------------------------------------
pro photonshoot,nofphot,mask,source
;------------------------------------------------------------------------------
source=create_struct('radius',3,'theta',0,'phi',0,'pos',[0,0,10])
;source.radius
;source.theta
;source.phi
;source.pos
;------------------------------------------------------------------------------

  radius=randomu(systime(1),nofphot)*(source.radius)
  angle=randomu(systime(1),nofphot)*2*!pi
  pos=dblarr(nofphot,3)
  for i=0,nofphot-1 do begin
     pos[i,0]= radius[i]*cos(source.theta)*cos(angle[i])+source.pos[0]
     pos[i,1]= radius[i]*sin(angle[i])*sin(source)+source.pos[1]
     pos[i,2]= radius[i]*sin(source.theta)*cos(angle[i])+source.pos[2]
  endfor

  
  

  

end
;******************************************************************************
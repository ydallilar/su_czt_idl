PRO main,data,ndata,efx,efz,wpa,wpc,wpst,eventnumb,plot=plot

geteventinfo,data,eventnumb,pos,ener
cloudnumb = n_elements(ener)
cloud = create_struct('xe_actual',dblarr(1000),'ze_actual',dblarr(1000),'te_actual',dblarr(1000))
holes = create_struct('xh_actual',dblarr(1000),'zh_actual',dblarr(1000),'th_actual',dblarr(1000))
cloud = replicate (cloud,cloudnumb)
holes = replicate (holes,cloudnumb)

cnte=0
cnth=0
timee = findgen(1000)*1e-9
timeh = findgen(1000)*10e-9

FOR i=0,cloudnumb-1 DO BEGIN
   electron_motion,0.,pos[0,i],pos[2,i],efx,efz,a,b,c,te_actual,xe_actual,ze_actual,coarsegridpos=[1.025,4.5]
   lene = floor(max(te_actual)*1e9)
   xe_actual=interpol(xe_actual,te_actual,timee[0:lene])
   ze_actual=interpol(ze_actual,te_actual,timee[0:lene])
   FOR j=0,lene DO BEGIN
      cloud[i].xe_actual[j]=xe_actual[j]
      cloud[i].ze_actual[j]=ze_actual[j]
   ENDFOR
   FOR j=lene+1,999 DO BEGIN
      cloud[i].xe_actual[j]=xe_actual[lene]
      cloud[i].ze_actual[j]=ze_actual[lene]
   ENDFOR
ENDFOR

FOR i=0,cloudnumb-1 DO BEGIN
   hole_motion,pos[0,i],pos[2,i],efx,efz,a,b,c,th_actual,xh_actual,zh_actual,coarsegridpos=[1.025,4.5]
   lenh = floor(max(th_actual)*1e8)
   xh_actual=interpol(xh_actual,th_actual,timeh[0:lenh])
   zh_actual=interpol(zh_actual,th_actual,timeh[0:lenh])
   FOR j=0,lenh DO BEGIN
      holes[i].xh_actual[j]=xh_actual[j]
      holes[i].zh_actual[j]=zh_actual[j]
   ENDFOR
   FOR j=lenh,999 DO BEGIN
      holes[i].xh_actual[j]=xh_actual[lenh]
      holes[i].zh_actual[j]=zh_actual[lenh]
   ENDFOR
ENDFOR

IF keyword_set(plot) THEN BEGIN
   FOR i=0,cloudnumb-1 DO BEGIN
      xe_actual = reform(cloud[i].xe_actual[where(cloud[i].xe_actual ne 0 )])
      ze_actual = reform(cloud[i].ze_actual[where(cloud[i].ze_actual ne 0 )])
      trajectory,xe_actual,ze_actual,i
   ENDFOR
   FOR i=0,cloudnumb-1 DO BEGIN
      xe_actual = reform(holes[i].xh_actual[where(holes[i].xh_actual ne 0 )])
      ze_actual = reform(holes[i].zh_actual[where(holes[i].zh_actual ne 0 )])
      trajectory,xe_actual,ze_actual,1,/hole
   ENDFOR
ENDIF

taue = 3e-6 
tauh = 1e-6
Qr_e = ener   ;???????? 2 choosen as bandgap !!!multiply by e
QAinde = dblarr(16,1000)
QCinde = dblarr(16,1000)
QSTinde = dblarr(5,1000)
Qr_h = -ener   ;???????? 2 choosen as bandgap !!!multiply by e
QAindh = dblarr(16,1000)
QCindh = dblarr(16,1000)
QSTindh = dblarr(5,1000)
q = dblarr(cloudnumb)

FOR m=0,999 DO BEGIN
   cloudsize,result,timearr,ftime=timee[m]
   sigma = result(n_elements(result)-1)
   grid_dist,sigma,1,calc
   FOR i=0,cloudnumb-1 DO BEGIN
      x=floor(cloud[i].xe_actual[m]/0.005)
      z=floor(cloud[i].ze_actual[m]/0.005)
      IF z gt 5 THEN q[i] = Qr_e[i]*exp(-timee[m]/taue)
      FOR k=0,0 DO BEGIN
         FOR j=0,15 DO BEGIN
           QAinde[j,m] = QAinde[j,m] + wpa[j,x+2*k-0,z]*calc[k]*q[i]
           QCinde[j,m] = QCinde[j,m] + wpc[j,x+2*k-0,z]*calc[k]*q[i]
           IF (j lt 5) THEN QSTinde[j,m] = QSTinde[j,m] + wpst[j,x+2*k-8,z]*calc[k]*q[i]
        ENDFOR
     ENDFOR
   ENDFOR
ENDFOR

FOR m=0,999 DO BEGIN
   FOR i=0,cloudnumb-1 DO BEGIN
      x=floor(holes[i].xh_actual[m]/0.005)
      z=floor(holes[i].zh_actual[m]/0.005)
      IF holes[i].zh_actual[m] lt 4.98 THEN q[i] = Qr_h[i]*exp(-timeh[m]/5*tauh)
      FOR j=0,15 DO BEGIN
         QAindh[j,m] = QAindh[j,m] + wpa[j,x,z]*q[i]
         QCindh[j,m] = QCindh[j,m] + wpc[j,x,z]*q[i]
         IF (j lt 5) THEN QSTindh[j,m] = QSTindh[j,m] + wpst[j,x,z]*q[i]
      ENDFOR
   ENDFOR
ENDFOR

qa=dblarr(16,1000)
qc=dblarr(16,1000)
qst=dblarr(5,1000)

FOR i=0,15 DO BEGIN
   qainde[i,*] = interpol(qainde[i,*],timee,timeh)
   qcinde[i,*] = interpol(qcinde[i,*],timee,timeh)
   qa[i,*] = qainde[i,*] + qaindh[i,*]
   qc[i,*] = qainde[i,*] + qcindh[i,*]
   IF i lt 5 THEN BEGIN
      qstinde[i,*] = interpol(qstinde[i,*],timee,timeh)
      qst[i,*] = qstinde[i,*] + qstindh[i,*]
   ENDIF
ENDFOR

time=timeh

stop

END

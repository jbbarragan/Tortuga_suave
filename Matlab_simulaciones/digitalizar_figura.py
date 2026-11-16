from PIL import Image
import numpy as np
from pathlib import Path
from scipy.optimize import least_squares
import json
R=Path(__file__).resolve().parent
im=np.array(Image.open(R.parent/'fig3_paper.png').convert('RGB')).astype(float)
# Figure 3b image calibration, pixels in source 1977 x 2246.
x0=128.; x1=230.3; y0=1631.5; y80=1296.;T=4.3
Y,X=np.indices(im.shape[:2]);r,g,b=im[:,:,0],im[:,:,1],im[:,:,2]
roi=(X>=128)&(X<=1007)&(Y>=1296)&(Y<=1967)&~((X<314)&(Y<1460))
masks=[(g>110)&(r<90)&(b<100),(b>160)&(r>70)&(r<210)&(g<100),(r>210)&(g>100)&(g<220)&(b<120)]
data=[];coef=[];rms=[]
def design(t):return np.column_stack([np.ones(len(t))]+[f(2*np.pi*j*t/T) for j in range(1,9) for f in (np.cos,np.sin)])
for name,mask in zip(['roll','yaw','pitch'],masks):
 points=[]
 for x in range(135,1000):
  yy=np.where((mask&roi)[:,x])[0]
  if len(yy):points.append([(x-x0)/(x1-x0),(y0-np.median(yy))*80/(y0-y80)])
 a=np.array(points);data.append(a)
 if name!='pitch':
  A=design(a[:,0]);c=np.linalg.lstsq(A,a[:,1],rcond=None)[0]
  coef.append(c);rms.append(float(np.sqrt(np.mean((A@c-a[:,1])**2))))
 # comma delimited image-derived points, not measured sensor data
 np.savetxt(R/f'digitalizado_{name}.csv',a,delimiter=',',header='t_s,angulo_deg',comments='')
np.savetxt(R/'fourier8_fig3.csv',np.array(coef).T,delimiter=',',header='roll_deg,yaw_deg',comments='')
# Six-piece linear pitch from Fig 3b, fit break times and plateaus to colored pixels.
a=data[2];ph=np.mod(a[:,0],T)
def pred(v):
 knots=[0,v[0],v[1],v[2],v[3],v[4],T];vals=[0,v[5],v[5],0,v[6],v[6],0]
 return np.interp(ph,knots,vals)
v=least_squares(lambda v:pred(v)-a[:,1],[.4,2.3,2.7,3.05,3.65,35,-72],bounds=([.25,2.1,2.55,2.9,3.5,30,-77],[.55,2.45,2.85,3.2,3.85,40,-67]),loss='soft_l1').x
knots=np.array([0,*v[:5],T]);values=np.array([0,v[5],v[5],0,v[6],v[6],0])
np.savetxt(R/'pitch_fig3.csv',np.c_[knots,values],delimiter=',',header='t_s,pitch_deg',comments='')
(R/'procedencia.json').write_text(json.dumps({'source':'https://www.nature.com/articles/s41598-023-37904-5/figures/3','image_url':'https://media.springernature.com/full/springer-static/image/art%3A10.1038%2Fs41598-023-37904-5/MediaObjects/41598_2023_37904_Fig3_HTML.png','method':'Color-pixel median per column; least-squares periodic Fourier8 for roll/yaw; robust piecewise-linear fit pitch. Not original coefficients.','pixel_calibration':{'x_t0':x0,'x_t1':x1,'y_deg0':y0,'y_deg80':y80},'period_s':T,'phase_boundaries_s':[0,.82,2.02,2.62,3.47,4.3],'roll_yaw_fit_pixel_RMSE_deg':rms,'pitch_knots_s':knots.tolist(),'pitch_values_deg':values.tolist(),'pitch_fit_pixel_RMSE_deg':float(np.sqrt(np.mean((pred(v)-a[:,1])**2)))},indent=2))
print((R/'procedencia.json').read_text())

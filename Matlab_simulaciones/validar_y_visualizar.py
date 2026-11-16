from pathlib import Path
import numpy as np,json
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from matplotlib.animation import FuncAnimation,FFMpegWriter
R=Path(__file__).resolve().parent
C=np.loadtxt(R/'fourier8_fig3.csv',delimiter=',',skiprows=1);PV=np.loadtxt(R/'pitch_fig3.csv',delimiter=',',skiprows=1)
T=4.3;edges=np.array([0,.82,2.02,2.62,3.47,4.3]);names=['RS1','US','RS2','DS','SS'];colors=['#669e4a','#8870a2','#a88a55','#3a71a9','#b37f9a']
def raw(t):
 t=np.asarray(t);ph=t%T
 A=np.stack([np.ones_like(ph)]+[f(2*np.pi*j*ph/T) for j in range(1,9) for f in [np.cos,np.sin]],axis=-1)
 return np.deg2rad(np.concatenate([A@C,np.interp(ph,PV[:,0],PV[:,1])[...,None]],axis=-1))
def ref(t):
 q=raw(t);ph=t%T;e=.04;dist=(ph-PV[:-1,0]+T/2)%T-T/2;i=np.argmin(abs(dist))
 if abs(dist[i])<e:
  center=PV[i,0];a=center-e;b=center+e;h=1e-6;qa=raw(a)[2];qb=raw(b)[2];da=(raw(a+h)[2]-raw(a-h)[2])/(2*h);db=(raw(b+h)[2]-raw(b-h)[2])/(2*h);u=(dist[i]+e)/(2*e);L=2*e;c=np.linalg.solve([[1,1,1],[3,4,5],[6,12,20]],[qb-qa-L*da,L*(db-da),0]);q[2]=qa+L*da*u+c[0]*u**3+c[1]*u**4+c[2]*u**5
 return q
shoulder=np.array([.055,.075,-.012]);arm=.04;span=.12;sweep=0;rootOffset=.08
s=np.linspace(0,span,61);eta=np.linspace(-.5,.5,15);S,E=np.meshgrid(s,eta,indexing='ij')
sp=np.array([0,15,35,60,78,95,108,118,120])/1000
ch=np.interp(s,sp,np.array([32,42,46,37,29,23,18,6,1])/1000)
le=np.interp(s,sp,np.array([8,8,8,8,8,8,7,2,.5])/1000)
X0=E*ch[:,None]+le[:,None]-ch[:,None]/2
def rx(a):return np.array([[1,0,0],[0,np.cos(a),-np.sin(a)],[0,np.sin(a),np.cos(a)]])
def rz(a):return np.array([[np.cos(a),-np.sin(a),0],[np.sin(a),np.cos(a),0],[0,0,1]])
def tip(q):return shoulder+rx(q[0])@(np.array([0,arm,0])+rz(-q[1])@np.array([-sweep*np.cos(q[2]),rootOffset+span,sweep*np.sin(q[2])]))
def surface(q):
 th=q[2]*np.clip((S-.020)/.055,0,1);P=shoulder[:,None]+rx(q[0])@(np.array([0,arm,0])[:,None]+rz(-q[1])@np.array([(X0*np.cos(th)).ravel(),(rootOffset+S).ravel(),(-X0*np.sin(th)).ravel()]))
 return P.reshape((3,*S.shape))
t=np.linspace(0,2*T,861);Q=np.array([ref(x) for x in t]);P=np.array([tip(q) for q in Q]);closure=np.linalg.norm(P[0]-P[-1]);assert closure<1e-12
assert tip([0,np.deg2rad(20),0])[0]>tip([0,np.deg2rad(-20),0])[0]
# Check smoothing derivatives match across corner patches, and positions stay finite.
for c in PV[:-1,0]:
 for boundary in [c-.04,c+.04]:
  h=1e-6
  jump=(ref(boundary+h)[2]-ref(boundary)[2])/h-(ref(boundary)[2]-ref(boundary-h)[2])/h
  assert abs(jump)<.002
assert np.all(np.isfinite(P))
report={'implementation':'Independent Python evaluation of same reference and kinematics; MATLAB not executed','cycle_closure_error_m':closure,'positive_yaw_moves_towards_positive_X':True,'pitch_blending_C1_boundary_check':True,'angles_min_deg':np.rad2deg(Q).min(axis=0).tolist(),'angles_max_deg':np.rad2deg(Q).max(axis=0).tolist(),'landmarks_at_phase_boundaries_m':{names[min(i,4)]+'_'+str(x):tip(ref(x)).tolist() for i,x in enumerate(edges)},'not_validated':'Exact anatomical offsets, absolute size, hydrodynamic forces, real robot'}
(R/'validacion.json').write_text(json.dumps(report,indent=2))
fig,axs=plt.subplots(3,1,figsize=(11,8),sharex=True)
for j,(ax,name) in enumerate(zip(axs,['roll','yaw','pitch'])):
 data=np.loadtxt(R/f'digitalizado_{name}.csv',delimiter=',',skiprows=1)
 for cycle in range(2):
  for i in range(5):ax.axvspan(edges[i]+cycle*T,edges[i+1]+cycle*T,color=colors[i],alpha=.12);ax.text((edges[i]+edges[i+1])/2+cycle*T,77,names[i],ha='center',fontsize=8)
 ax.scatter(data[::5,0],data[::5,1],s=6,c='gray',alpha=.5,label='Pixeles digitalizados')
 ax.plot(t,np.rad2deg(Q[:,j]),color=['#00a000','#8000ff','#efa300'][j],lw=1.7,label='Referencia revisada');ax.set_ylim(-85,85);ax.set_ylabel(name+' [°]');ax.grid(alpha=.2)
axs[0].legend(loc='lower center',ncol=2);axs[-1].set_xlabel('Tiempo [s]');axs[-1].set_xlim(0,8.6);fig.suptitle('Figura 3b: reconstrucción desde imagen, no coeficientes originales');fig.tight_layout();fig.savefig(R/'Comparacion_angulos.png',dpi=150);plt.close(fig)
# Side/top/front comparisons: exact transformed coordinates, chronologic arrows.
fig,axs=plt.subplots(1,3,figsize=(13,4.5));pairs=[(0,2),(0,1),(1,2)];labels=['X hacia cabeza [m]','Y izquierda [m]','Z arriba [m]']
for ax,(i,j),name in zip(axs,pairs,['Lateral','Superior','Frontal']):
 for a in range(5):
  ind=np.where((t>=edges[a])&(t<=edges[a+1]))[0];ax.plot(P[ind,i],P[ind,j],color=colors[a],lw=2,label=names[a]);k=ind[len(ind)//2];ax.annotate('',xy=P[k+6,[i,j]],xytext=P[k,[i,j]],arrowprops={'arrowstyle':'->','color':colors[a]})
 ax.scatter(shoulder[i],shoulder[j],c='black',s=20);ax.set_xlabel(labels[i]);ax.set_ylabel(labels[j]);ax.set_title(name);ax.set_aspect('equal');ax.grid(alpha=.3)
axs[0].legend(fontsize=8);fig.suptitle('Variante SG90: punta rígida · flechas = avance del ciclo');fig.tight_layout();fig.savefig(R/'Trayectorias_corregidas.png',dpi=150);plt.close(fig)
# 4-view animation with unambiguous head position.
fig=plt.figure(figsize=(8,6));views=[(0,-90),(90,-90),(0,0),(25,-55)];axes=[];surfs=[];titles=[]
u=np.linspace(0,2*np.pi,32);v=np.linspace(0,np.pi/2,14);UU,VV=np.meshgrid(u,v)
body=np.array([.10*np.cos(UU)*np.cos(VV),.07*np.sin(UU)*np.cos(VV),.068*np.sin(VV)])
head=np.array([.113+.023*np.cos(UU)*np.cos(VV),.024*np.sin(UU)*np.cos(VV),.005+.018*np.sin(VV)])
for idx,(el,az) in enumerate(views):
 ax=fig.add_subplot(2,2,idx+1,projection='3d');axes.append(ax);ax.plot_surface(*body,color='#388343',alpha=.8,linewidth=0);ax.plot_surface(*head,color='#59a456',linewidth=0)
 ax.quiver(.13,0,.10,.07,0,0,color='black');ax.text(.13,0,.125,'+X cabeza',fontsize=8)
 for a in range(5):
  ind=(t>=edges[a])&(t<=edges[a+1]);ax.plot(*P[ind].T,':',color=colors[a]);Pr=P[ind].copy();Pr[:,1]*=-1;ax.plot(*Pr.T,':',color=colors[a])
 ax.set(xlim=(-.2,.24),ylim=(-.34,.34),zlim=(-.23,.24),xlabel='X',ylabel='Y',zlabel='Z');ax.set_box_aspect((.44,.60,.47));ax.view_init(el,az);titles.append(ax.set_title(''))
 surfs.append([])
def update(frame):
 tk=frame/12;q=ref(tk);F=surface(q);a=min(np.searchsorted(edges,tk%T,side='right')-1,4)
 for k,ax in enumerate(axes):
  for artist in surfs[k]:artist.remove()
  mirror=F.copy();mirror[1]*=-1
  surfs[k]=[ax.plot_surface(*F,color=colors[a],linewidth=0),ax.plot_surface(*mirror,color=colors[a],linewidth=0)]
  titles[k].set_text(['Lateral','Superior','Frontal','3D'][k]+f' | {names[a]} | {tk:.2f} s')
 return []
fig.tight_layout();update(40);fig.savefig(R/'Vista_corregida.png',dpi=140)
plt.close(fig)
print(json.dumps(report,indent=2))

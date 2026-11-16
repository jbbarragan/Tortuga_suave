function out=movimiento_aletas(medio,animar,calcularCargas)
% REVISION 3 SG90: reconstruccion CINEMATICA de Figura 3, no dinamica validada.
% out=movimiento_aletas; out=movimiento_aletas('agua',false);
% Coeficientes DIGITALIZADOS de imagen, no coeficientes originales del autor.
% https://doi.org/10.1038/s41598-023-37904-5 (Fig.3)
% MATLAB base R2019b+. Archivo autonomo, no necesita CSV para ejecutarse.
if nargin<1,medio='agua';end
if nargin<2,animar=true;end
if nargin<3,calcularCargas=false;end
if calcularCargas,error('Las cargas de esta variante SG90 requieren calibracion e inercia del mecanismo; no se habilita el modelo anterior.');end
if ~strcmp(medio,'agua')
 error('Esta revision compara la natacion de Fig.3; no genera marcha terrestre.');
end
p.T=4.3; % periodo de la figura; 0.23 Hz es su frecuencia redondeada
p.f=1/p.T;p.dt=p.T/430;p.cycles=2;
p.edges=[0 .82 2.02 2.62 3.47 4.3];p.names={'RS1','US','RS2','DS','SS'};
p.colors=[.40 .66 .29;.49 .38 .65;.64 .48 .25;.20 .43 .67;.71 .39 .58];
p.arm=.040;p.rootOffset=.080;p.L=.120;p.shoulder=[.055;.075;-.012];
p.span=[0 15 35 60 78 95 108 118 120]*1e-3;
p.chord=[32 42 46 37 29 23 18 6 1]*1e-3;
p.leading=[8 8 8 8 8 8 7 2 .5]*1e-3;
% Geometria CAD V3; superficie media, no calculo de deformacion elastica.
% Raiz 0:20 mm fija; torsion idealizada 20:75; inserto distal 75:120 rigido.
p.C=[3.17368760646 0.971958038321;
-60.5755855958 -25.1757995319;
-19.1782318085 -22.2099598313;
-5.54302395157 -8.59435723583;
14.8856246385 -2.0855344889;
0.805632859586 -2.59361019862;
2.70049024162 0.303928501619;
1.0953663409 -0.929773223906;
-0.205200410464 -0.719750082665;
-1.82128702201 -0.205413147255;
0.101721105455 0.435217850143;
-1.29001815364 0.0205741699893;
-0.575197241122 0.188817314324;
0.00618478351862 -0.00745696371671;
0.0969345904371 0.13466321359;
-0.0575336981276 -0.0649049746064;
0.0235496014545 0.155247810284]; % a0,a1,b1,...,a8,b8; columnas roll,yaw [deg]
p.pitchTimes=[0 0.393938758027 2.30608015129 2.7018507857 3.02459642996 3.66026062107 4.3];p.pitchValues=[0 34.9882155699 34.9882155699 0 -71.6943468509 -71.6943468509 0];
p.pitchBlend=.04; % s; redondeo C2 de quiebres; 0 replica la curva lineal
p.playback=1; % tiempo fisico / tiempo de reloj; .5 = camara lenta
% Ejes cuerpo: +X cabeza, +Y izquierda, +Z arriba.
% Cadena: roll en hombro, yaw LOCAL en codo, torsion distribuida.
% Signo yaw escogido para que yaw positivo lleve la aleta hacia +X.
% La figura no basta para identificar todos los offsets anatomicos exactos.
t=(0:p.dt:p.cycles*p.T)';n=numel(t);Q=zeros(n,3);literal=Q;
tip=zeros(n,3);elbow=zeros(n,3);h=1e-4;vel=tip;acc=tip;
for k=1:n
 Q(k,:)=reference(t(k),p)';literal(k,:)=referenceRaw(t(k),p)';
 [tip(k,:),elbow(k,:)]=landmarks(Q(k,:)',p);
 pm=landmarks(reference(t(k)-h,p),p);pp=landmarks(reference(t(k)+h,p),p);
 vel(k,:)=(pp-pm)/(2*h);acc(k,:)=(pp-2*tip(k,:)+pm)/h^2;
end
assert(norm(reference(0,p)-reference(p.T,p))<1e-10,'Error de cierre');
assert(norm(tip(1,:)-tip(end,:))<1e-9,'Trayectoria no periodica');
% Verificacion explicita: yaw positivo => avance de la aleta hacia cabeza
pa=landmarks([0;deg2rad(-20);0],p);pb=landmarks([0;deg2rad(20);0],p);
assert(pb(1)>pa(1),'Yaw esta invertido');
% Separar las comparaciones cinematicas de fuerzas no validadas
figure('Name','Figura 3b - reconstruccion digitalizada','Color','w');
for j=1:3
 subplot(3,1,j);hold on;phaseBands(p,[-85 85],p.cycles);
 plot(t,rad2deg(literal(:,j)),'--','Color',[.65 .65 .65],'LineWidth',1);
 cols=[0 .65 0;.5 0 1;1 .60 0];plot(t,rad2deg(Q(:,j)),'Color',cols(j,:),'LineWidth',1.6);
 names={'roll','yaw','pitch'};ylabel([names{j} ' [deg]']);ylim([-85 85]);xlim([0 t(end)]);grid on;
 if j==1,title('Fig.3b: digitalizacion aproximada; no coeficientes originales');end
 if j==3,xlabel('Tiempo [s]');legend('Reconstruccion lineal/Fourier','Referencia suavizada','Location','best');end
end
figure('Name','Trayectorias de la punta - ejes corporales','Color','w');
views={[1 3],[1 2],[2 3]};labels={'X hacia cabeza [m]','Y izquierda [m]','Z arriba [m]'};
for j=1:3
 ax=subplot(1,3,j);hold on;ij=views{j};
 for a=1:5
  sel=t>=p.edges(a)&t<=p.edges(a+1);
  plot(tip(sel,ij(1)),tip(sel,ij(2)),'Color',p.colors(a,:),'LineWidth',2);
  ids=find(sel);m=ids(round(numel(ids)/2));step=3;
  quiver(tip(m,ij(1)),tip(m,ij(2)),tip(m+step,ij(1))-tip(m,ij(1)),tip(m+step,ij(2))-tip(m,ij(2)),0,'Color',p.colors(a,:),'HandleVisibility','off');
 end
 scatter(p.shoulder(ij(1)),p.shoulder(ij(2)),40,'k','filled','HandleVisibility','off');
 xlabel(labels{ij(1)});ylabel(labels{ij(2)});axis equal;grid on;
 titles={'Lateral XZ','Superior XY','Frontal YZ'};title(titles{j});
 if j==1,legend(p.names,'Location','best');end
end
% Mismo arreglo 3 x 5 de Fig.3a, posturas cada 0.08 s
figure('Name','Secuencia RS1 US RS2 DS SS','Color','w');
for row=1:3
 for phase=1:5
  ax=subplot(3,5,(row-1)*5+phase);hold(ax,'on');body(ax);
  plot3(tip(1:431,1),tip(1:431,2),tip(1:431,3),':','Color',[.55 .55 .55]);
  ts=unique([p.edges(phase):.08:p.edges(phase+1),p.edges(phase+1)]);
  for tk=ts
   qk=reference(tk,p);[X,Y,Z]=surfaceFin(qk,p);
   [~,ep]=landmarks(qk,p);
   for side=[-1 1],plot3(ax,[p.shoulder(1) ep(1)],side*[p.shoulder(2) ep(2)],[p.shoulder(3) ep(3)],'Color',p.colors(phase,:),'LineWidth',1);end
   surf(ax,X,Y,Z,'FaceColor',p.colors(phase,:),'EdgeColor','none','FaceAlpha',.28);
   surf(ax,X,-Y,Z,'FaceColor',p.colors(phase,:),'EdgeColor','none','FaceAlpha',.28);
  end
  configure(ax,row);title(sprintf('%s | %.2f-%.2f s',p.names{phase},p.edges(phase:phase+1)));
 end
end
if animar
 fig=figure('Name','Aleteo corregido - cabeza hacia +X','Color','w');
 ha=gobjects(4,2);hs=gobjects(4,2);markers=gobjects(4,1);axs=gobjects(4,1);
 for j=1:4
  ax=subplot(2,2,j);axs(j)=ax;hold(ax,'on');body(ax);configure(ax,j);
  for a=1:5
   sel=t>=p.edges(a)&t<=p.edges(a+1);
   plot3(ax,tip(sel,1),tip(sel,2),tip(sel,3),':','Color',p.colors(a,:));
   plot3(ax,tip(sel,1),-tip(sel,2),tip(sel,3),':','Color',p.colors(a,:));
  end
  [X,Y,Z]=surfaceFin(Q(1,:)',p);
  hs(j,1)=surf(ax,X,Y,Z,'FaceColor',[.2 .65 .35],'EdgeColor','none');
  hs(j,2)=surf(ax,X,-Y,Z,'FaceColor',[.2 .65 .35],'EdgeColor','none');
  for side=1:2,ha(j,side)=plot3(ax,nan,nan,nan,'Color',[.22 .42 .24],'LineWidth',4);end
  markers(j)=plot3(ax,tip(1,1),tip(1,2),tip(1,3),'ko','MarkerFaceColor','y');
 end
 clock=tic;
 while isgraphics(fig)
  elapsed=toc(clock)*p.playback;k=min(n,1+floor(elapsed/p.dt));
  [X,Y,Z]=surfaceFin(Q(k,:)',p);a=phaseIndex(t(k),p);
  for j=1:4
   set(hs(j,1),'XData',X,'YData',Y,'ZData',Z,'FaceColor',p.colors(a,:));
   set(hs(j,2),'XData',X,'YData',-Y,'ZData',Z,'FaceColor',p.colors(a,:));
   for side=1:2,sgn=3-2*side;set(ha(j,side),'XData',[p.shoulder(1) elbow(k,1)],'YData',sgn*[p.shoulder(2) elbow(k,2)],'ZData',[p.shoulder(3) elbow(k,3)]);end
   set(markers(j),'XData',tip(k,1),'YData',tip(k,2),'ZData',tip(k,3));
   title(axs(j),sprintf('%s | t=%.2f s',p.names{a},t(k)));
  end
  drawnow;if k==n,break;end;pause(.005);
 end
end
out=struct('t',t,'q_rad',Q,'q_figura_rad',literal,'tip_m',tip,'elbow_m',elbow,'tip_vel_m_s',vel,'tip_acc_m_s2',acc,'p',p);
out.aviso='Reconstruccion desde imagen; no validacion fisica ni anatomica exacta.';

folder=fullfile(fileparts(mfilename('fullpath')),'resultados_fig3');if ~isfolder(folder),mkdir(folder);end
writetable(array2table([t,rad2deg(Q),tip],'VariableNames',{'t_s','roll_deg','yaw_deg','pitch_deg','tipX_m','tipY_m','tipZ_m'}),fullfile(folder,'cinematica_fig3.csv'));
save(fullfile(folder,'cinematica_fig3.mat'),'out');
fprintf('Revision 3 SG90: T=%.2f s, f=%.5f Hz. Cabeza +X. Datos digitalizados de Fig.3.\n',p.T,p.f);
end
function q=referenceRaw(t,p)
 ph=mod(t,p.T);A=1;
 for j=1:8,A=[A cos(2*pi*j*ph/p.T) sin(2*pi*j*ph/p.T)];end %#ok<AGROW>
 q=deg2rad([A*p.C interp1(p.pitchTimes,p.pitchValues,ph,'linear')])';
end
function q=reference(t,p)
 q=referenceRaw(t,p);e=p.pitchBlend;if e<=0,return;end
 % C2 smoothing only within +/- e of piecewise-linear pitch corners.
 ph=mod(t,p.T);knots=p.pitchTimes(1:end-1);dist=mod(ph-knots+p.T/2,p.T)-p.T/2;
 [d,i]=min(abs(dist));if d>=e,return;end
 center=knots(i);a=center-e;b=center+e;
 qa=referenceRaw(a,p);qb=referenceRaw(b,p);dh=1e-6;
 qam=referenceRaw(a-dh,p);qap=referenceRaw(a+dh,p);qbm=referenceRaw(b-dh,p);qbp=referenceRaw(b+dh,p);
 da=(qap(3)-qam(3))/(2*dh);db=(qbp(3)-qbm(3))/(2*dh);
 u=(dist(i)+e)/(2*e);L=2*e;
 c0=qa(3);c1=L*da;c2=0;
 coeff=[1 1 1;3 4 5;6 12 20]\[qb(3)-c0-c1;L*db-c1;0];
 q(3)=c0+c1*u+c2*u^2+coeff(1)*u^3+coeff(2)*u^4+coeff(3)*u^5;
end
function [X,Y,Z]=surfaceFin(q,p)
 s=linspace(0,p.L,41)';eta=linspace(-.5,.5,15);
 [S,E]=ndgrid(s,eta);c=interp1(p.span,p.chord,s);
 x=E.*c+interp1(p.span,p.leading,s,'linear')-c/2;
 theta=q(3)*min(max((S-.020)/.055,0),1);
 local=[reshape(x.*cos(theta),1,[]);(p.rootOffset+S(:))';reshape(-x.*sin(theta),1,[])];
 points=p.shoulder+rx(q(1))*([0;p.arm;0]+rz(-q(2))*local);
 X=reshape(points(1,:),size(S));Y=reshape(points(2,:),size(S));Z=reshape(points(3,:),size(S));
end
function [tip,elbow]=landmarks(q,p)
 local=[0;p.rootOffset+p.L;0];
 elbow=p.shoulder+rx(q(1))*[0;p.arm;0];
 tip=(elbow+rx(q(1))*rz(-q(2))*local)';elbow=elbow';
end
function a=phaseIndex(t,p)
 a=find(mod(t,p.T)>=p.edges(1:end-1),1,'last');
end
function phaseBands(p,lims,cycles)
 for cycle=0:cycles-1
  for j=1:5
   a=cycle*p.T+p.edges(j);b=cycle*p.T+p.edges(j+1);
   patch([a b b a],[lims(1) lims(1) lims(2) lims(2)],p.colors(j,:),'FaceAlpha',.075,'EdgeColor','none','HandleVisibility','off');
   text((a+b)/2,lims(2)-8,p.names{j},'HorizontalAlignment','center','FontSize',8,'HandleVisibility','off');
  end
 end
end
function body(ax)
 [x,y,z]=ellipsoid(0,0,0,.10,.07,.068,24);z(z<0)=0;
 surf(ax,x,y,z,'FaceColor',[.20 .50 .22],'EdgeColor','none','FaceAlpha',.70);
 [x,y,z]=ellipsoid(.113,0,.005,.023,.02,.016,15);
 surf(ax,x,y,z,'FaceColor',[.3 .6 .25],'EdgeColor','none');
 for side=[-1 1]
  fill3(ax,[-.1 -.18 -.16 -.09],side*[.045 .12 .13 .08],[-.015 -.02 -.02 -.015],[.25 .55 .30]);
 end
 quiver3(ax,.13,0,.09,.07,0,0,0,'k','LineWidth',1.3,'MaxHeadSize',.8);
 text(ax,.145,0,.11,'+X cabeza','FontSize',8);
end
function configure(ax,j)
 axis(ax,'equal');grid(ax,'on');xlim(ax,[-.2 .24]);ylim(ax,[-.34 .34]);zlim(ax,[-.23 .24]);
 if j==1,view(ax,0,0);xlabel(ax,'X adelante');zlabel(ax,'Z arriba');
 elseif j==2,view(ax,0,90);xlabel(ax,'X adelante');ylabel(ax,'Y izquierda');
 elseif j==3,view(ax,90,0);ylabel(ax,'Y izquierda');zlabel(ax,'Z arriba');
 else,view(ax,40,25);xlabel(ax,'X');ylabel(ax,'Y');zlabel(ax,'Z');end
end
function R=rx(a),R=[1 0 0;0 cos(a) -sin(a);0 sin(a) cos(a)];end
function R=rz(a),R=[cos(a) -sin(a) 0;sin(a) cos(a) 0;0 0 1];end


// mm. Prototipo de horquilla sobre maneta, NO estriado de servo.
// Usa el horn original del servo, atornillado a la placa superior.
// Confirmar estas medidas con calibrador antes de fabricar seis unidades.
$fn=64;
maneta_largo=24; maneta_ancho=5; holgura_total=0.8;
altura_mordaza=10; placa=4; pared=4;
agujero_horn=2.2; separacion_horn=14; acceso_central=5;
L=maneta_largo+holgura_total+2*pared;
W=maneta_ancho+holgura_total+2*pared;
difference(){
 union(){
  // placa en cama, mordazas hacia arriba: sin soportes
  translate([-L/2,-W/2,0]) cube([L,W,placa]);
  for(s=[-1,1]) translate([-L/2,s*(maneta_ancho+holgura_total)/2-(s<0?pared:0),placa])
   cube([L,pared,altura_mordaza]);
 }
 cylinder(h=placa+1,d=acceso_central);
 for(x=[-separacion_horn/2,separacion_horn/2])
  translate([x,0,-1]) cylinder(h=placa+2,d=agujero_horn);
 // alojamiento hexagonal para tuerca M3; tornillo corto presiona la maneta
 translate([0,-W/2-0.01,placa+altura_mordaza/2]) rotate([-90,0,0]) cylinder(h=2.5,d=6.6,$fn=6);
 // paso del tornillo M3
 translate([0,-W,placa+altura_mordaza/2]) rotate([-90,0,0]) cylinder(h=2*W,d=3.2);
}

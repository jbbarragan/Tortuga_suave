# Pendientes y referencias

## Pendientes

| Prioridad | Tarea | Dónde se refleja |
|---|---|---|
| Alta | Probar y grabar la aleta hecha con el molde e inserto actuales; registrar presión y desplazamiento | Sección 04 |
| Alta | Ampliar el firmware a 10 servos (aletas traseras) | Sección 06 |
| Alta | Calibrar el pulso de cada una de las diez válvulas (0°/45°/90°) | Sección 06 |
| Media | Medir peso, caudal y presión de válvula con servo contra solenoide | Sección 06 |
| Media | Confirmar con calibrador el acople y fabricar los diez | Sección 05 |
| Media | Ejecutar `movimiento_aletas.m` en MATLAB y comparar con la implementación en Python | Sección 03 |
| Media | Registrar grado de Ecoflex, tiempos de curado y desgasificado | Sección 01 |
| Baja | Relacionar medidas de la punta de la aleta con los ángulos roll, yaw y pitch | Sección 02 |

## Referencias

1. van der Geest, N., Garcia, L., Nates, R., Godoy, D. A. *New insight into the swimming kinematics of wild Green sea turtles (Chelonia mydas).* Scientific Reports 12, 18151 (2022). doi:10.1038/s41598-022-21459-y
2. van der Geest, N., Garcia, L., Borret, F., Nates, R., Gonzalez, A. *Soft-robotic green sea turtle (Chelonia mydas) developed to replace animal experimentation provides new insight into their propulsive strategies.* Scientific Reports 13, 11983 (2023). doi:10.1038/s41598-023-37904-5
3. Rus, D., Tolley, M. T. *Design, fabrication and control of soft robots.* Nature 521, 467–475 (2015).
4. Ilievski, F., Mazzeo, A. D., Shepherd, R. F., Chen, X., Whitesides, G. M. *Soft robotics for chemists.* Angewandte Chemie International Edition 50, 1890–1895 (2011).
5. Mosadegh, B. et al. *Pneumatic networks for soft robotics that actuate rapidly.* Advanced Functional Materials 24, 2163–2170 (2014).
6. Polygerinos, P. et al. *Soft robotics: review of fluid-driven intrinsically soft devices; manufacturing, sensing, control, and applications in human-robot interaction.* Advanced Engineering Materials 19, 1700016 (2017).

## Archivos descargables

- [STL: inserto v9](STL/Inserto_junta_triangular_v9.stl), [inserto v7](STL/Inserto_junta_triangular_v7.stl), [molde v7](STL/Molde_junta_triangular_v7.stl)
- [Proyecto de impresión del molde (.3mf)](Molde_aleta.3mf)
- [Acople: STL](cople_prototipo.stl) y [fuente OpenSCAD](cople_parametrico.scad)
- [Firmware ESP32-S3](Aletas_ESP32S3/Aletas_ESP32S3.ino)
- [Script MATLAB](Matlab_simulaciones/movimiento_aletas.m)
- [Video original de la primera prueba, con audio](Fallos_aprendizajes/prueba_aleta_1.mp4)

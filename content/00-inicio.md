# Tortuga suave: aletas neumáticas de silicón

<p class="lead">Reporte técnico del avance del proyecto: un robot inspirado en la tortuga marina cuyas aletas son actuadores neumáticos de silicón (Ecoflex), controlados por una secuencia de válvulas accionadas con servomotores.</p>

<div class="stats">
<div class="stat"><b>10</b><span>servos / válvulas en total</span></div>
<div class="stat"><b>3 + 3</b><span>canales en las aletas delanteras</span></div>
<div class="stat"><b>2 + 2</b><span>canales en las aletas traseras</span></div>
<div class="stat"><b>5</b><span>estados por ciclo de control</span></div>
<div class="stat"><b>9.5 s</b><span>duración del ciclo actual</span></div>
<div class="stat"><b>4.3 s</b><span>periodo de la cinemática de referencia</span></div>
</div>

<div class="abstract">
<p><strong>Resumen—</strong> Este trabajo documenta el diseño preliminar y la evolución experimental de un sistema de aletas neumáticas bioinspiradas en la locomoción de la tortuga marina. Se presenta el fundamento biomecánico, la reconstrucción periódica de trayectorias mediante series de Fourier, la fabricación iterativa de actuadores de silicona, una arquitectura de tres cámaras por aleta anterior y una estrategia de control secuencial con ESP32-S3, bomba y válvulas accionadas por servomotores. La documentación integra modelos tridimensionales, firmware, simulaciones y evidencia visual. Los resultados disponibles corresponden principalmente a modelado cinemático, diseño y pruebas iniciales; el desempeño mecánico e hidrodinámico del prototipo vigente requiere caracterización experimental.</p>
<p class="keywords"><strong>Palabras clave—</strong> Robótica suave, bioinspiración, actuadores neumáticos, Ecoflex, tortuga marina, ESP32-S3, series de Fourier, manufactura aditiva.</p>
</div>

## I. Introducción y alcance

La locomoción de organismos acuáticos constituye una referencia para el desarrollo de sistemas robóticos flexibles. En este trabajo se plantea una aleta neumática de silicona cuyo movimiento se produce mediante la presurización selectiva de conductos internos. La estrategia integra modelado cinemático, manufactura de moldes e insertos y control electrónico. El objetivo de este documento es presentar una trazabilidad técnica de las decisiones de diseño y distinguir los resultados simulados de los aún no verificados en el prototipo físico.

El análisis se organiza en ocho apartados: fundamentos de robótica suave, referencia biomecánica, reconstrucción cinemática, iteraciones de fabricación, diseño del prototipo, arquitectura neumática, simulación de la secuencia y trabajo experimental pendiente, seguido de referencias bibliográficas. Los archivos de origen y los recursos de validación se conservan íntegramente en el paquete del proyecto.

## II. Enfoque metodológico

El proceso seguido comprende: (i) identificación de una cinemática biológica de referencia; (ii) aproximación periódica de las variables angulares y visualización de trayectorias; (iii) construcción iterativa de moldes y vías internas; (iv) definición del sistema neumático de accionamiento; y (v) evaluación conceptual de la máquina de estados. Para cada etapa se distinguen los artefactos de diseño, las evidencias disponibles y las verificaciones que siguen pendientes.

**Criterio de interpretación:** la existencia de un modelo CAD, una simulación o un programa de control no constituye por sí misma evidencia de capacidad de carga, eficiencia de propulsión, presión alcanzada en cada cámara ni desempeño estable en agua.

## Estado actual

| Área | Estado | Comentario |
|---|---|---|
| Cinemática de referencia (Fourier) | <span class="badge ok">Hecho</span> | Ciclo periódico reconstruido, 5 fases, ver sección 03 |
| Molde e inserto (STL) | <span class="badge ok">Versión actual</span> | Inserto v9, molde v7; v7 del inserto se conserva para comparar |
| Primera aleta | <span class="badge wip">Fallida, documentada</span> | Adherencia entre dos vaciados y celdas tipo cubo que limitaban el movimiento |
| Secuencia neumática | <span class="badge ok">Definida</span> | Firmware ESP32-S3 con 6 servos (aletas delanteras) y simulación web |
| Servos de aletas traseras (4) | <span class="badge wip">En diseño</span> | Falta extender el firmware a los 10 canales |
| Prueba con aleta del molde actual | <span class="badge wip">Pendiente de documentar</span> | Agregar video y resultados cuando existan |

Este reporte describe lo que existe en el repositorio al día de hoy. Lo que no está medido o probado aparece marcado como pendiente en lugar de darse por hecho.

## III. Discusión del estado de desarrollo

El avance evidencia una integración progresiva entre el diseño del cuerpo flexible, la ubicación geométrica de los conductos neumáticos y las órdenes de control. La separación funcional de los canales T, P y D permite proponer movimientos de abducción, elevación y aducción; sin embargo, la relación entre presurización, deformación y desplazamiento de la punta todavía debe determinarse mediante instrumentación y ensayos repetibles.

En la etapa electrónica, la máquina de estados especifica cinco acciones neumáticas y transiciones de aislamiento. Su temporización constituye un perfil de mando y no debe confundirse con una respuesta dinámica validada del elastómero. La extrapolación a todas las aletas requiere ampliar y verificar los canales del firmware, las conexiones y la capacidad del sistema neumático.

## IV. Conclusiones preliminares

Se ha establecido un flujo de diseño documentado que conecta una referencia biomecánica con modelos cinemáticos, geometrías fabricables y un esquema reproducible de control. La principal contribución del prototipo en su estado actual es la integración de estos componentes y el registro de las iteraciones, no la demostración cuantitativa de locomoción o capacidad de carga. La siguiente etapa debe incluir mediciones de presión por cámara, desplazamientos de punta, repetibilidad, fugas, consumo eléctrico y respuesta frente a ciclos consecutivos.

**Organización del material complementario:** los archivos STL y 3MF, el código MATLAB y Python, el firmware Arduino, los videos y las fotografías originales forman parte del proyecto y acompañan al presente informe.

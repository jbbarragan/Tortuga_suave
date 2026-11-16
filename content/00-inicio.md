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

## De qué trata este reporte

El proyecto busca reproducir con un robot blando el movimiento de aleteo de la tortuga marina. Este documento reúne, en el orden en que se fue construyendo el trabajo:

1. **Fundamentos**: qué es la robótica suave y por qué encaja con este problema ([sección 01](#/robotica-suave)).
2. **Bioingeniería**: el movimiento real de la aleta de la tortuga y lo que esperamos replicar ([sección 02](#/bioingenieria)).
3. **Simulación**: la reconstrucción cinemática en MATLAB con series de Fourier ([sección 03](#/matlab)).
4. **Iteraciones**: la primera aleta que no funcionó y lo que aprendimos ([sección 04](#/iteraciones)).
5. **Prototipo actual**: molde, inserto, visor 3D de los STL finales y acople del servo ([sección 05](#/prototipo)).
6. **Control neumático**: válvulas de tres posiciones con servo, bomba y secuencia de inflado ([sección 06](#/neumatica)).
7. **Simulación interactiva** de la secuencia de las dos aletas ([sección 07](#/simulacion)).

## Estado actual

| Área | Estado | Comentario |
|---|---|---|
| Cinemática de referencia (Fourier) | <span class="badge ok">Hecho</span> | Ciclo periódico reconstruido, 5 fases, ver sección 03 |
| Molde e inserto (STL) | <span class="badge ok">Versión actual</span> | Inserto v9, molde v7; v7 del inserto se conserva para comparar |
| Primera aleta | <span class="badge wip">Fallida, documentada</span> | Adherencia entre dos vaciados y celdas tipo cubo que limitaban el movimiento |
| Secuencia neumática | <span class="badge ok">Definida</span> | Firmware ESP32-S3 con 6 servos (aletas delanteras) y simulación web |
| Servos de aletas traseras (4) | <span class="badge wip">En diseño</span> | Falta extender el firmware a los 10 canales |
| Prueba con aleta del molde actual | <span class="badge wip">Pendiente de documentar</span> | Agregar video y resultados cuando existan |

> [!NOTA] Este reporte describe lo que existe en el repositorio al día de hoy. Lo que no está medido o probado aparece marcado como pendiente en lugar de darse por hecho.

## Mapa del repositorio

```text
Tortuga_suave/
├── index.html                  ← este reporte (GitHub Pages / Codespace)
├── content/                    ← texto del reporte en Markdown (editable)
│   ├── index.json              ← orden de las secciones
│   └── stl.json                ← modelos que muestra el visor 3D
├── assets/                     ← estilos, scripts, librerías locales, video e imágenes
├── STL/                        ← molde e insertos actuales
├── cople_prototipo.stl         ← acople horquilla–maneta de la válvula
├── cople_parametrico.scad      ← fuente paramétrica (OpenSCAD) del acople
├── Molde_aleta.3mf             ← proyecto de impresión del molde
├── Aletas_ESP32S3/             ← firmware (Arduino-ESP32 3.x)
├── Matlab_simulaciones/        ← MATLAB, Python, CSV y figuras de la cinemática
├── Fallos_aprendizajes/        ← fotos y video original de la primera aleta
├── simulacion_aletas.html      ← simulación interactiva de la secuencia
├── diagrama_estados.png        ← máquina de estados del ciclo
└── .devcontainer/ .github/     ← Codespace y despliegue en GitHub Pages
```

## Cómo ver y editar este reporte

- **GitHub Pages**: se publica automáticamente al subir cambios a `main` (ver `README.md`).
- **Codespace**: al abrirlo arranca un servidor local y reenvía el puerto 8000; el reporte se abre en una vista previa.
- **Edición**: cada sección es un archivo `content/*.md`. Se cambia el texto sin tocar HTML. Para agregar una sección, crea el `.md` y añádelo a `content/index.json`.

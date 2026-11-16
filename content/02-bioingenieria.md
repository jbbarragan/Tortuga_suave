# Bioingeniería: la aleta de la tortuga marina

<p class="lead">La bioingeniería aplica principios de ingeniería a sistemas vivos, y en su vertiente de bioinspiración toma de la naturaleza soluciones ya optimizadas por evolución. Aquí la fuente de inspiración es el aleteo de la tortuga marina.</p>

## Bioinspiración: copiar el principio, no el animal

Replicar un organismo no significa copiarlo pieza por pieza. Significa identificar **qué hace** el sistema biológico (generar empuje con una pala flexible que cambia de forma) y resolverlo con la tecnología disponible. Las tortugas marinas son un buen caso: nadan con las aletas delanteras en un movimiento descrito como un "vuelo subacuático", y el cuerpo blando de la aleta se tuerce para mantener un buen ángulo de ataque.

## Cómo aletea una tortuga verde

Van der Geest y colaboradores filmaron tortugas verdes (*Chelonia mydas*) en libertad y describieron el movimiento de la aleta como un ciclo cerrado en tres dimensiones dividido en **cinco fases**:

| Fase | Nombre | Descripción |
|---|---|---|
| RS1 | Recovery stroke 1 | Primera fase de recuperación |
| US | Upstroke | Carrera ascendente |
| RS2 | Recovery stroke 2 | Segunda fase de recuperación |
| DS | Downstroke | Carrera descendente |
| SS | Sweep stroke | Barrido de la punta hacia el centro del caparazón, descrito por los autores como un movimiento de "aplauso" |

El orden del ciclo es RS1 → US → RS2 → DS → SS, y es el mismo que usa la simulación de este proyecto.

Su trabajo posterior con una tortuga robótica blanda reporta que la tortuga solo produce empuje durante cerca del 30 % del ciclo y aprovecha el 70 % restante para planear con poco arrastre. El movimiento se puede reducir a **tres ángulos**: *roll* (rotación en el hombro), *yaw* (movimiento de barrido en el codo) y *pitch* (torsión de la aleta a lo largo de su envergadura).

## Lo que queremos lograr

El siguiente video es la reconstrucción cinemática del ciclo, con la cabeza hacia +X y las fases coloreadas. Es el movimiento objetivo que el prototipo neumático debe aproximar.

<figure>
<video controls loop muted playsinline preload="metadata" src="Matlab_simulaciones/Aleteo_corregido.mp4"></video>
<figcaption>Aleteo corregido: reconstrucción del ciclo de 4.3 s (dos ciclos) en cuatro vistas, lateral, superior, frontal y 3D. La punta de la aleta recorre una trayectoria cerrada.</figcaption>
</figure>

<div class="grid2">
<figure><img src="Matlab_simulaciones/Trayectorias_corregidas.png" alt="Trayectorias de la punta de la aleta en vistas lateral, superior y frontal"><figcaption>Trayectorias de la punta por fase: el recorrido es un lazo cerrado.</figcaption></figure>
<figure><img src="Matlab_simulaciones/Vista_corregida.png" alt="Vistas lateral, superior, frontal y 3D del modelo de tortuga con aletas"><figcaption>Vistas del modelo en una fase (DS, t = 3.33 s).</figcaption></figure>
</div>

Este movimiento ya está **simulado con series de Fourier** (detalles en la [sección 03](#/matlab)).

## De la biología al actuador

Una aleta real tiene músculos, huesos y piel. La versión neumática reduce eso a tres vías de aire dentro de un cuerpo de silicón. Cada vía, al inflarse, produce una flexión en una dirección:

| Canal | Efecto buscado en la aleta |
|---|---|
| **T** | Abducción: la aleta se abre hacia afuera |
| **P** | Elevación: la aleta sube |
| **D** | Aducción: la aleta se cierra hacia adentro |

Inflar y desinflar los canales en la secuencia correcta aproxima el lazo de la punta. La correspondencia con los ángulos roll, yaw y pitch es **conceptual**: todavía no se ha medido cuánto se desplaza la punta de la aleta real con cada canal.

La referencia cinemática se obtuvo digitalizando la Figura 3 del artículo; no son los coeficientes originales de los autores ni una validación hidrodinámica. Qué falta por validar está en la [sección 03](#/matlab).

## Referencias de esta sección

- van der Geest, N., Garcia, L., Nates, R., Godoy, D. A. *New insight into the swimming kinematics of wild Green sea turtles (Chelonia mydas).* Sci. Rep. 12, 18151 (2022). [doi:10.1038/s41598-022-21459-y](https://doi.org/10.1038/s41598-022-21459-y)
- van der Geest, N., Garcia, L., Borret, F., Nates, R., Gonzalez, A. *Soft-robotic green sea turtle (Chelonia mydas) developed to replace animal experimentation provides new insight into their propulsive strategies.* Sci. Rep. 13, 11983 (2023). [doi:10.1038/s41598-023-37904-5](https://doi.org/10.1038/s41598-023-37904-5)

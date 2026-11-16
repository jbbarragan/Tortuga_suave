# Iteraciones, fallos y aprendizajes

<p class="lead">Documentar lo que no funcionó es parte del resultado. La primera aleta falló por dos decisiones de fabricación, y de esas fallas salió el diseño actual.</p>

## Iteración 1: primera aleta

La primera aleta se coló en un molde impreso en 3D y se probó en un banco neumático.

<div class="grid2">
<figure><img src="Fallos_aprendizajes/aleta_fallida1.jpg" alt="Aleta de silicón translúcido sobre su molde impreso naranja"><figcaption>La aleta de la primera iteración sobre su molde.</figcaption></figure>
<figure><img src="Fallos_aprendizajes/molde_cubos.jpg" alt="Aleta translúcida y las dos mitades del molde negro, una con hileras de cubos"><figcaption>Molde con hileras de cubos y la aleta que produjo.</figcaption></figure>
</div>

### Evidencia: la prueba en video

El video muestra la aleta conectada con manguera al banco neumático (regulador con manómetro y electroválvula). Se grabó con audio y se le **quitó el sonido** para publicarlo como evidencia.

<figure style="max-width:380px">
<video controls muted playsinline preload="metadata" src="assets/video/prueba_aleta_1_sin_audio.mp4"></video>
<figcaption>Prueba de la primera aleta (sin audio, 1 min). En lugar de una flexión controlada se ven abombamientos locales cuando entra el aire.</figcaption>
</figure>

<<<<<<< HEAD
La descripción del video es una lectura de lo que se ve en él. Si recuerdas con exactitud la presión usada y en qué punto falló la aleta, agrégalo aquí para dejar el registro completo.
=======
<<<<<<< HEAD
La descripción del video es una lectura de lo que se ve en él. Si recuerdas con exactitud la presión usada y en qué punto falló la aleta, agrégalo aquí para dejar el registro completo.
=======
> [!NOTA] La descripción del video es una lectura de lo que se ve en él. Si recuerdas con exactitud la presión usada y en qué punto falló la aleta, agrégalo aquí para dejar el registro completo.
>>>>>>> 7becdd6392672aaff77769c75e5f0a4774b02834
>>>>>>> 348622558d5b2030a604535e15bc167e44b02d49

## Problema 1: adherencia entre dos vaciados

Para formar las vías de aire la aleta se hizo en **dos vaciados**: una primera capa de silicón y una segunda sobre ella. La interfaz entre ambas quedó como una costura débil: ahí quedaban las vías, y la unión no resistía la presión.

<figure style="max-width:460px">
<img src="Fallos_aprendizajes/error_vias_2vaciados.jpg" alt="Extremo de la aleta con tres orificios circulares de las vías, atravesado por la línea de unión de los dos vaciados">
<figcaption>Extremo de la aleta: se ven las tres vías y la línea donde se unen los dos vaciados.</figcaption>
</figure>

**Por qué pasa.** El silicón curado casi no se adhiere a silicón curado: la segunda capa se "apoya" sobre la primera sin formar un enlace tan fuerte como el del material continuo. Funciona mejor cuando la segunda capa se vierte con la primera todavía pegajosa (curado parcial), o con un adhesivo de silicón, y aun así sigue siendo el punto débil.

**Qué se decidió.** Pasar a un diseño donde las vías se forman con un **inserto** (los pernos impresos del [prototipo actual](#/prototipo)) y la aleta se cuela de una sola pieza, para que el silicón sea continuo alrededor de cada vía.

## Problema 2: los cubos limitaban el movimiento

El primer molde tenía hileras de **cubos** para formar cámaras en la aleta. Los cubos dejaban paredes entre cámaras que **rigidizaban** el cuerpo y **limitaban el movimiento**: la aleta no se doblaba en el eje deseado al inflar.

**Qué se decidió.** Eliminar las cámaras de cubos y usar **vías continuas, largas y con posiciones desfasadas** entre sí, de modo que cada vía flexione la aleta en una dirección concreta ([sección 05](#/prototipo)).

## Resumen de aprendizajes

| Qué falló | Causa | Decisión de diseño |
|---|---|---|
| Vías que se despegaban a presión | Dos vaciados: la unión silicón–silicón era débil | Colada en una sola pieza con inserto formador de vías |
| La aleta no flexionaba | Cubos que rigidizaban y repartían el aire en celdas | Vías continuas, desfasadas, sin cámaras de cubos |
| Prueba solo con un banco fijo | Electroválvulas y regulador de laboratorio, sin secuencia | Electrónica propia con válvulas de servo y secuencia automática ([sección 06](#/neumatica)) |

## Qué sigue

<<<<<<< HEAD
Documentar con video la primera prueba de la aleta fabricada con el molde e inserto actuales, con su presión de operación y el ángulo logrado, y compararla con las fases de la simulación.
=======
<<<<<<< HEAD
Documentar con video la primera prueba de la aleta fabricada con el molde e inserto actuales, con su presión de operación y el ángulo logrado, y compararla con las fases de la simulación.
=======
> [!PENDIENTE] Documentar con video la primera prueba de la aleta fabricada con el molde e inserto actuales, con su presión de operación y el ángulo logrado, y compararla con las fases de la simulación.
>>>>>>> 7becdd6392672aaff77769c75e5f0a4774b02834
>>>>>>> 348622558d5b2030a604535e15bc167e44b02d49

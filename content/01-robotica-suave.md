# Introducción a la robótica suave

<p class="lead">La robótica suave construye máquinas con materiales que se deforman como lo hacen los tejidos vivos. En lugar de articulaciones rígidas con motores, el movimiento surge de la deformación controlada del propio cuerpo.</p>

## Qué es

Un robot **suave** (*soft robot*) está hecho principalmente de materiales con módulos de elasticidad bajos, comparables a los de la piel, los músculos o los tentáculos. Rus y Tolley (2015) ubican esos materiales en el orden de 10<sup>4</sup> a 10<sup>9</sup> Pa, frente a 10<sup>9</sup> a 10<sup>12</sup> Pa de los metales y plásticos rígidos con los que se hacen los robots clásicos.

Esa diferencia cambia la forma de diseñar:

| Robot rígido | Robot suave |
|---|---|
| Pocos grados de libertad en articulaciones discretas | Deformación continua, en principio infinitos grados de libertad |
| Motor + reductor + eslabón | El material mismo es el actuador y la estructura |
| Precisión por geometría y encoders | Comportamiento no lineal, histéresis, difícil de modelar |
| Riesgo al contacto con personas o entornos frágiles | Seguro e inherentemente compatible con el contacto |
| Mecanismo pesado y caro | Ligero, barato de moldear, pero con menor fuerza y rapidez |

## Formas de actuarlos

Las familias más usadas son:

- **Neumática o hidráulica (actuadores elastoméricos fluídicos)**: canales o cámaras dentro de un elastómero que se inflan con aire o líquido. Es la que usa este proyecto.
- **Cables o tendones**: un motor tira de un cable embebido.
- **Aleaciones con memoria de forma (SMA)**: se contraen al calentarse.
- **Elastómeros dieléctricos**: se comprimen bajo un campo eléctrico.
- **Músculos neumáticos tipo McKibben**: fibras trenzadas que se acortan al inflarse.

Dentro de la actuación neumática, los trabajos clásicos son el gripper de estrella de mar de Ilievski y colaboradores (2011) y las *redes neumáticas* (PneuNets) de Mosadegh y colaboradores (2014), donde una hilera de cámaras se infla y, al estar unida a una capa que no se estira, el conjunto se curva.

## Por qué la neumática encaja con una aleta

La aleta de una tortuga marina no es un eslabón que gira: es una pala flexible que se **curva, se tuerce y cambia de ángulo de ataque** a lo largo del ciclo. Un cuerpo de silicón con varias vías de aire permite:

1. Doblarse en más de una dirección eligiendo qué canal se infla.
2. Ser ligero y sin partes metálicas expuestas al agua dentro de la aleta.
3. Fabricarse con un molde impreso en 3D y silicón vaciado, sin mecanizados complejos.

El costo es el control: no hay sensores de posición en el elastómero, así que el movimiento se gobierna con **secuencias de inflado y desinflado** en lazo abierto. Eso es justo lo que resuelve la electrónica descrita en la [sección 06](#/neumatica).

## El material: Ecoflex

Las aletas se fabrican con **Ecoflex** (Smooth-On), una familia de silicones de platino de dos partes, A y B, que se mezclan en proporción 1:1 en volumen y curan a temperatura ambiente. Son blandos (la escala va de Shore 00-10 a 00-50 según el grado), muy elásticos y soportan grandes deformaciones, lo que los hace habituales en actuadores neumáticos.

<figure style="max-width:420px">
<img src="assets/img/ecoflex_jeringas.jpg" alt="Cubetas azul y amarilla de Ecoflex, un garrafón, una botella y dos jeringas de 550 cc dentro de un auto">
<figcaption>Material de trabajo: las dos cubetas (partes A y B del Ecoflex) y dos jeringas de 550 cc con las que se pueden medir y trasvasar volúmenes iguales de cada parte.</figcaption>
</figure>

Proceso general de colada con este tipo de silicón:

1. Medir partes A y B en igual volumen (de ahí las jeringas graduadas).
2. Mezclar a fondo y, si es posible, **desgasificar** para sacar las burbujas.
3. Verter en el molde con el inserto que forma las vías de aire.
4. Curar el tiempo indicado por la ficha del fabricante y desmoldar.

<<<<<<< HEAD
Anotar aquí el grado exacto de Ecoflex usado (00-10, 00-30, 00-50…), el tiempo de curado real y si se desgasifica al vacío. Son datos que hacen reproducible la aleta.

El silicón ya curado se pega mal a silicón curado. Ese detalle fue la causa de la primera falla, y se explica en la [sección 04](#/iteraciones).
=======
> [!PENDIENTE] Anotar aquí el grado exacto de Ecoflex usado (00-10, 00-30, 00-50…), el tiempo de curado real y si se desgasifica al vacío. Son datos que hacen reproducible la aleta.

> [!AVISO] El silicón ya curado se pega mal a silicón curado. Ese detalle fue la causa de la primera falla, y se explica en la [sección 04](#/iteraciones).
>>>>>>> 7becdd6392672aaff77769c75e5f0a4774b02834

## Referencias de esta sección

- Rus, D., Tolley, M. T. *Design, fabrication and control of soft robots.* Nature 521, 467–475 (2015).
- Ilievski, F. et al. *Soft robotics for chemists.* Angew. Chem. Int. Ed. 50, 1890–1895 (2011).
- Mosadegh, B. et al. *Pneumatic networks for soft robotics that actuate rapidly.* Adv. Funct. Mater. 24, 2163–2170 (2014).
- Polygerinos, P. et al. *Soft robotics: review of fluid-driven intrinsically soft devices…* Adv. Eng. Mater. 19, 1700016 (2017).

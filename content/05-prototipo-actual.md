# Prototipo actual

<p class="lead">El diseño vigente reúne un molde, un inserto que forma tres vías de aire desfasadas y un acople para mover cada válvula con un servo. Los archivos STL de esta sección son los finales actuales.</p>

## Visor de los STL actuales

Gira, acerca y activa varios modelos a la vez. La **versión v9** del inserto está visible por defecto; activa la **v7** con "Semitransparente" para comparar cómo cambió la separación de las vías.

<div data-stl-viewer="actuales"></div>

| Pieza | Archivo | Dimensiones (mm) |
|---|---|---|
| Inserto de vías, versión actual | `STL/Inserto_junta_triangular_v9.stl` | 80 × 32 × 182.8 |
| Inserto de vías, versión anterior | `STL/Inserto_junta_triangular_v7.stl` | 80 × 32 × 182.8 |
| Molde de la aleta | `STL/Molde_junta_triangular_v7.stl` | 176 × 72 × 31 |

El proyecto de impresión del molde está en `Molde_aleta.3mf` (laminado para Creality, cuatro objetos).

## El inserto: tres varillas que forman las vías

El inserto es un bloque base de 80 × 32 × 28 mm del que salen **tres varillas** de unos 3.6 mm de diámetro y cerca de 155 mm de largo. Al colar el silicón alrededor, cada varilla deja un canal por el que luego entra el aire. Las varillas **no son paralelas**: parten separadas en la base y **convergen hacia la punta**, siguiendo el estrechamiento de la aleta.

<figure style="max-width:420px">
<img src="assets/img/inserto_impreso_azul.jpg" alt="Pieza impresa en azul con tres pernos dentro de una cavidad de perfil trilobulado">
<figcaption>Pieza impresa en azul del prototipo: tres pernos dentro de una cavidad de perfil trilobulado, uno por vía.</figcaption>
</figure>

### Qué cambió de la v7 a la v9

Medido directamente en los STL (posiciones de los ejes de las varillas):

| Medida | v7 | v9 |
|---|---|---|
| Separación entre varillas laterales en la base (eje X) | ≈ 41 mm | ≈ 41 mm |
| Separación entre varillas laterales en la punta (eje X) | 20 mm | 31 mm |
| Posición de las laterales en la punta (eje Y) | ≈ 5.1 mm | ≈ 6.8 mm |
| Varilla central en la punta (X, Y) | 40, 22.4 mm | 40, 22.4 mm |
| Varilla central frente a las laterales | termina 8 mm más lejos | termina 8 mm más lejos |

En la v9 las varillas laterales **convergen menos** hacia la punta: pasan de 20 a 31 mm de separación, lo que deja más material entre vías y menos riesgo de que se toquen. La base y la varilla central no cambiaron.

## El desfase de las vías limita el movimiento a los ejes deseados

Las tres vías **no están alineadas**: dos van a los lados y una se desplaza en la otra dirección, formando un triángulo (de ahí "junta triangular"). Ese desfase es el que da dirección al movimiento.

<figure>
<svg viewBox="0 0 720 300" role="img" aria-label="Esquema de la sección con tres vías en triángulo: D a la izquierda, T a la derecha y P arriba, con flechas de flexión" style="width:100%;height:auto;background:#10253a;border:1px solid #2c4055;border-radius:12px">
<defs><marker id="ar" markerWidth="8" markerHeight="8" refX="6" refY="4" orient="auto"><path d="M0,0 L8,4 L0,8 z" fill="#ffd578"/></marker></defs>
<rect x="150" y="60" width="240" height="190" rx="46" fill="#1b3d4d" stroke="#a1c2c9" stroke-width="2"/>
<line x1="270" y1="40" x2="270" y2="270" stroke="#3d5467" stroke-dasharray="4 5"/>
<line x1="130" y1="170" x2="410" y2="170" stroke="#3d5467" stroke-dasharray="4 5"/>
<circle cx="205" cy="200" r="20" fill="#66efb4" fill-opacity=".25" stroke="#66efb4" stroke-width="3"/>
<circle cx="335" cy="200" r="20" fill="#66efb4" fill-opacity=".25" stroke="#66efb4" stroke-width="3"/>
<circle cx="270" cy="115" r="20" fill="#5bb7ff" fill-opacity=".25" stroke="#5bb7ff" stroke-width="3"/>
<g font-family="system-ui,sans-serif" font-size="18" font-weight="700" text-anchor="middle" fill="#fff"><text x="205" y="207">D</text><text x="335" y="207">T</text><text x="270" y="122">P</text></g>
<path d="M205 240 Q175 262 140 262" stroke="#ffd578" stroke-width="3" fill="none" marker-end="url(#ar)"/>
<path d="M335 240 Q365 262 400 262" stroke="#ffd578" stroke-width="3" fill="none" marker-end="url(#ar)"/>
<path d="M270 72 Q270 48 270 30" stroke="#ffd578" stroke-width="3" fill="none" marker-end="url(#ar)"/>
<g font-family="system-ui,sans-serif" font-size="15" fill="#c9dcec">
<text x="440" y="90">Vías laterales D y T: se desplazan</text><text x="440" y="110">a los lados del plano central.</text>
<text x="440" y="132" fill="#ffd578">→ flexión de lado a lado</text>
<text x="440" y="175">Vía central P: se desplaza en la</text><text x="440" y="195">otra dirección (hacia el borde).</text>
<text x="440" y="217" fill="#ffd578">→ flexión hacia arriba (elevación)</text>
<text x="440" y="262" fill="#8aa4bd" font-size="13">Esquema ilustrativo, no a escala.</text></g>
</svg>
<figcaption>Disposición triangular de las vías. La vía que se infla desplaza el material hacia su lado y curva la aleta en esa dirección.</figcaption>
</figure>

**Principio.** Una vía alejada del eje central, al inflarse, genera un momento de flexión: curva la aleta en la dirección que le toca. Con las vías desfasadas en dos direcciones se consiguen **dos planos de flexión independientes**:

- **D y T** (laterales) mueven la aleta hacia adentro y hacia afuera: aducción y abducción.
- **P** (central, desplazada en la otra dirección y que termina 8 mm más lejos) levanta la aleta.
- Inflar **D y P juntas** produce un movimiento diagonal que combina aducción con elevación, y es justo el estado 3 de la secuencia.

Así se evita la flexión incontrolada del primer prototipo: cada vía "tiene un eje", y el movimiento solo ocurre en los ejes que se eligieron al diseñar el inserto.

<<<<<<< HEAD
La orientación de D (izquierda) y T (derecha) sigue la simulación de la [sección 07](#/simulacion). El sentido físico final depende de cómo se conecte cada vía al servo.
=======
> [!NOTA] La orientación de D (izquierda) y T (derecha) sigue la simulación de la [sección 07](#/simulacion). El sentido físico final depende de cómo se conecte cada vía al servo.
>>>>>>> 7becdd6392672aaff77769c75e5f0a4774b02834

## El acople servo–válvula

Cada válvula se mueve con un servo. Para unir el *horn* del servo con la maneta de la válvula se diseñó un acople tipo **horquilla** (`cople_parametrico.scad`), con estas ideas:

- Usa el **horn original** del servo, atornillado a la placa superior (dos agujeros de 2.2 mm separados 14 mm).
- Dos mordazas abrazan la maneta de 24 × 5 mm con 0.8 mm de holgura.
- Un tornillo M3 con tuerca hexagonal atrapada presiona la maneta y evita el juego.
- Se imprime con la placa sobre la cama y las mordazas hacia arriba, **sin soportes**.

<div data-stl-viewer="cople"></div>

<figure style="max-width:620px">
<img src="vista_cople.png" alt="Vista 3D del acople horquilla con placa y mordazas">
<figcaption>Vista del acople generada desde el modelo (32.8 × 13.8 × 14 mm).</figcaption>
</figure>

<<<<<<< HEAD
Las dimensiones del acople son provisionales (así lo indica el propio `.scad`). Confirmar con calibrador la maneta de la válvula antes de fabricar los diez acoples.
=======
> [!PENDIENTE] Las dimensiones del acople son provisionales (así lo indica el propio `.scad`). Confirmar con calibrador la maneta de la válvula antes de fabricar los diez acoples.
>>>>>>> 7becdd6392672aaff77769c75e5f0a4774b02834

## Siguiente: cómo se mueve el aire

El control de las vías, la bomba y la secuencia está en la [sección 06](#/neumatica).

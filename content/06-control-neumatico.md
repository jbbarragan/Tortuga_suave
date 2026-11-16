# Control neumático: válvulas con servo

<p class="lead">Una sola bomba alimenta todas las vías. Cada vía tiene su propia válvula de tres posiciones movida por un servo, y un microcontrolador ESP32-S3 ejecuta la secuencia de inflado y desinflado.</p>

## Arquitectura

```text
                ┌──────────┐
   Bomba ──────►│ colector │──► válvula 1 (servo) ──► vía de aleta
  (on/off)      │  común   │──► válvula 2 (servo) ──► vía de aleta
                └────┬─────┘    …  (10 válvulas en total)
                     │
              escape común 2/2 (normalmente abierto) ──► atmósfera
```

| Elemento | Función |
|---|---|
| **ESP32-S3** | Ejecuta la secuencia y genera los PWM de los servos |
| **Bomba** | Se enciende solo en los estados de inflado (salidas `IN1`/`IN2`) |
| **Válvulas de 3 posiciones + servo** | Cada una cierra, conecta a la bomba o conecta al escape |
| **Escape común 2/2 normalmente abierto** | Libera el aire; se cierra mientras la bomba infla (vía MOSFET con diodo) |
| **Paro (STOP)** | Contacto normalmente cerrado: si se pulsa o se rompe el cable, todo se detiene |
| **Inicio (START)** | Botón con antirrebote de 30 ms |

## La válvula de tres posiciones

Cada servo gira su válvula entre tres posiciones, de modo que **una misma válvula** decide qué le pasa a su vía:

| Posición | Pulso (provisional) | Efecto en la vía |
|---|---|---|
| **0°** | 1000 µs | Cerrada: la vía conserva el aire que tiene |
| **45°** | 1250 µs | Conectada a la bomba: se **infla** |
| **90°** | 1500 µs | Conectada al escape: se **desinfla** |

En reposo (paro) las válvulas quedan a 90° con la bomba apagada y el escape abierto: nada queda presurizado.

<<<<<<< HEAD
Los pulsos 1000 / 1250 / 1500 µs del firmware son valores provisionales para un servo de 180°. Cada válvula debe calibrarse por separado (posiciones físicas 0/45/90). Si un servo está invertido, se invierte la fila de calibración de esa válvula, no se intercambian canales.
=======
> [!AVISO] Los pulsos 1000 / 1250 / 1500 µs del firmware son valores provisionales para un servo de 180°. Cada válvula debe calibrarse por separado (posiciones físicas 0/45/90). Si un servo está invertido, se invierte la fila de calibración de esa válvula, no se intercambian canales.
>>>>>>> 7becdd6392672aaff77769c75e5f0a4774b02834

## Secuencia de inflado y desinflado

La secuencia ordena la bomba, el escape y las posiciones de las válvulas. Los canales son **T** (abducción), **P** (elevación) y **D** (aducción):

| Estado | Acción | T | P | D | Bomba | Duración |
|---|---|---|---|---|---|---|
| E1 | Inflar T | 45° | 0° | 0° | ON | 2 s |
| E2 | Desinflar T | 90° | 0° | 0° | OFF | 1 s |
| E3 | Inflar D + P | 0° | 45° | 45° | ON | 2 s |
| E4 | Desinflar P (D conserva el aire) | 0° | 90° | 0° | OFF | 1 s |
| E5 | Desinflar D | 0° | 0° | 90° | OFF | 1 s |

<figure style="max-width:460px">
<img src="diagrama_estados.png" alt="Diagrama de estados: paro, E1 inflar T, E2 desinflar T, E3 inflar D+P, E4 desinflar P, E5 desinflar D y regreso a E1">
<figcaption>Máquina de estados del ciclo. Tras E5 regresa a E1 y se repite.</figcaption>
</figure>

Entre estados el firmware pasa por **dos barreras** de 250 ms:

1. **ISOLATE**: se cierran todas las vías (0°) para que no se mezclen presiones.
2. **POSITION**: se colocan solo las válvulas que intervienen en el estado.
3. **ACTIVE**: se enciende o apaga la bomba durante el tiempo del estado.

Así el ciclo completo dura 7 s de acción + 5 × 0.5 s de transiciones = **9.5 s**. El truco del estado E4 es que **D se queda cerrada con su aire** mientras P se desinfla, y solo en E5 se libera: esa retención permite componer movimientos con una sola bomba.

```cpp
const Step seq[]={
 {"Inflar T",    {1,0,0},true, 2000},
 {"Desinflar T", {2,0,0},false,1000},
 {"Inflar D+P",  {0,1,1},true, 2000},
 {"Desinflar P", {0,2,0},false,1000},
 {"Desinflar D", {0,0,2},false,1000}
};   // 0 = cerrada, 1 = bomba, 2 = escape
```

## Por qué válvulas de servo y no solenoides

Elegimos mover válvulas de tres posiciones con servos en lugar de usar una electroválvula solenoide por vía. La razón es el **peso**: un robot que va a nadar debe ser ligero, y diez solenoides suman masa y consumo. Los modelos de electroválvula disponibles para electrónica de bajo costo además suelen obligar a elegir entre ligereza, caudal y presión; con la válvula de servo se conserva el caudal y la presión del conducto sin cargar con solenoides pesados.

| | Solenoide por vía | Válvula con servo |
|---|---|---|
| Peso | Mayor, uno por vía | Menor |
| Caudal y presión | Limitados por los modelos pequeños disponibles | Los del conducto de la válvula |
| Posiciones | 2 (abre/cierra) | 3 (cerrada, bomba, escape) en un solo dispositivo |
| Requisito | Driver por bobina | Un canal PWM por servo |

<<<<<<< HEAD
Falta registrar los números de esta comparación: masa de la válvula con su servo contra el solenoide equivalente, caudal y presión medidos. Con esos datos esta tabla pasa de argumento de diseño a resultado.
=======
> [!PENDIENTE] Falta registrar los números de esta comparación: masa de la válvula con su servo contra el solenoide equivalente, caudal y presión medidos. Con esos datos esta tabla pasa de argumento de diseño a resultado.
>>>>>>> 7becdd6392672aaff77769c75e5f0a4774b02834

El único solenoide que permanece es el **escape común** 2/2 normalmente abierto, que al estar abierto sin energía deja el sistema despresurizado ante cualquier falla.

## Diez servos, diez válvulas

| Aleta | Canales | Servos |
|---|---|---|
| Delantera izquierda | T, P, D | 3 |
| Delantera derecha | T, P, D | 3 |
| Trasera izquierda | 2 | 2 |
| Trasera derecha | 2 | 2 |
| **Total** | | **10** |

<<<<<<< HEAD
El firmware actual (`Aletas_ESP32S3.ino`) controla **6 servos**: las dos aletas delanteras, con las tres vías T, P, D cada una, moviéndose en espejo (`pos[i%3]`). Los 4 servos de las aletas traseras todavía no están en el código: hay que ampliar el arreglo `SERVO[]`, la tabla de pulsos y la secuencia para los 10 canales.
=======
> [!AVISO] El firmware actual (`Aletas_ESP32S3.ino`) controla **6 servos**: las dos aletas delanteras, con las tres vías T, P, D cada una, moviéndose en espejo (`pos[i%3]`). Los 4 servos de las aletas traseras todavía no están en el código: hay que ampliar el arreglo `SERVO[]`, la tabla de pulsos y la secuencia para los 10 canales.
>>>>>>> 7becdd6392672aaff77769c75e5f0a4774b02834

## Pines y seguridad del firmware

| Señal | GPIO |
|---|---|
| Servos T1, P1, D1, T2, P2, D2 | 1, 2, 4, 5, 6, 7 |
| Bomba `IN1`, `IN2` | 8, 9 |
| Escape `VENT` | 10 |
| `STOP` (contacto NC a GND) | 11 |
| `START` | 12 |

- **No arranca solo**: espera el botón START o el carácter `s` por el puerto serie (`x` detiene).
- **El paro manda**: STOP y `x` tienen prioridad sobre cualquier otro comando.
- **Falla segura**: si algo falla en el PWM, la bomba queda inhibida y las vías abiertas.
- El escape se acciona mediante un MOSFET con diodo; nunca se conecta la bobina directo al GPIO.
- PWM de 50 Hz con 14 bits de resolución (LEDC de Arduino-ESP32 3.x).

El código completo está en [`Aletas_ESP32S3/Aletas_ESP32S3.ino`](Aletas_ESP32S3/Aletas_ESP32S3.ino).
<<<<<<< HEAD

## Consideraciones para la validación del sistema neumático

Para caracterizar el conjunto se recomienda registrar, con una referencia temporal común, presión de salida de la bomba, presión de cada vía, corriente de los actuadores y posición efectiva de los servomotores. También se debe comprobar la condición de despresurización del sistema ante pérdida de energía, bloqueo de una válvula o activación del paro. Las posiciones angulares especifican la selección de un paso de aire; no determinan por sí solas la fracción real del caudal ni la presión resultante en la cámara.
=======
>>>>>>> 7becdd6392672aaff77769c75e5f0a4774b02834

# Simulación en MATLAB y series de Fourier

<p class="lead">Antes de moldear silicón conviene saber qué movimiento queremos. Para eso se reconstruyó en MATLAB la cinemática de la aleta a partir de la Figura 3 del artículo de 2023, representando los ángulos periódicos con series de Fourier.</p>

## Idea general

El aleteo es **periódico**: cada 4.3 s la aleta vuelve exactamente a su posición inicial. Una función periódica se puede escribir como suma de senos y cosenos (serie de Fourier), lo que da una expresión compacta y suave del ángulo en función del tiempo:

```text
ángulo(t) = a0 + Σ_{k=1..8} [ a_k·cos(2πk·t/T) + b_k·sin(2πk·t/T) ]      con T = 4.3 s
```

- **Roll** (hombro) y **yaw** (codo) se ajustan con **8 armónicos** cada uno.
- **Pitch** (torsión) tiene tramos casi rectos con mesetas (+35° y −72°), así que se ajusta con una curva **lineal por tramos** y se suaviza en las esquinas con un polinomio de quinto grado dentro de ±0.04 s para que la velocidad no tenga saltos.

## Cómo se obtuvieron los coeficientes

1. **Digitalización** (`digitalizar_figura.py`): se leen por color los píxeles de las curvas roll, yaw y pitch de la figura, se calibran los ejes (tiempo y grados) y se toma la mediana por columna. Resultado: `digitalizado_roll.csv`, `digitalizado_yaw.csv`, `digitalizado_pitch.csv`.
2. **Ajuste por mínimos cuadrados**: se calculan los 17 coeficientes de Fourier de roll y yaw (`fourier8_fig3.csv`) y los nodos de pitch (`pitch_fig3.csv`).
3. **Trazabilidad**: `procedencia.json` guarda la fuente, el método y los errores de ajuste.
4. **Cinemática** (`movimiento_aletas.m`): con los ángulos se mueve un modelo simple de hombro, codo y aleta (superficie media de 120 mm de envergadura) y se obtiene la trayectoria de la punta.

| Dato | Valor |
|---|---|
| Periodo | 4.3 s (≈ 0.23 Hz) |
| Error de ajuste roll / yaw / pitch (RMSE) | 1.78° / 0.85° / 1.18° |
| Rango de roll | −65.0° a +72.2° |
| Rango de yaw | −39.4° a +34.6° |
| Rango de pitch | −71.7° a +35.0° |
| Error de cierre del ciclo | 0 m (la punta vuelve al punto de inicio) |

### Fases del ciclo

| Fase | Inicio (s) | Fin (s) | Duración (s) |
|---|---|---|---|
| RS1 | 0.00 | 0.82 | 0.82 |
| US | 0.82 | 2.02 | 1.20 |
| RS2 | 2.02 | 2.62 | 0.60 |
| DS | 2.62 | 3.47 | 0.85 |
| SS | 3.47 | 4.30 | 0.83 |

## Fragmento del código

La evaluación de la serie en MATLAB (de `movimiento_aletas.m`):

```matlab
function q=referenceRaw(t,p)
 ph=mod(t,p.T);A=1;
 for j=1:8,A=[A cos(2*pi*j*ph/p.T) sin(2*pi*j*ph/p.T)];end
 q=deg2rad([A*p.C interp1(p.pitchTimes,p.pitchValues,ph,'linear')])';
end
```

Se ejecuta así (MATLAB R2019b o posterior, el archivo es autónomo):

```matlab
out = movimiento_aletas;            % animación + figuras + CSV en resultados_fig3/
out = movimiento_aletas('agua',false); % sin animación
```

## Resultados

<figure>
<img src="Matlab_simulaciones/Comparacion_angulos.png" alt="Curvas de roll, yaw y pitch digitalizadas y su reconstrucción con Fourier a lo largo de dos ciclos">
<figcaption>Roll, yaw y pitch: puntos digitalizados contra la reconstrucción. Las bandas de color marcan las cinco fases.</figcaption>
</figure>

<figure>
<img src="Matlab_simulaciones/Trayectorias_corregidas.png" alt="Trayectoria de la punta en tres vistas">
<figcaption>Trayectoria de la punta de la aleta en vistas lateral (XZ), superior (XY) y frontal (YZ).</figcaption>
</figure>

## Archivos de esta carpeta

| Archivo | Para qué sirve |
|---|---|
| [`movimiento_aletas.m`](Matlab_simulaciones/movimiento_aletas.m) | Simulación cinemática en MATLAB |
| [`validar_y_visualizar.py`](Matlab_simulaciones/validar_y_visualizar.py) | Evaluación independiente en Python, verificaciones y video |
| [`digitalizar_figura.py`](Matlab_simulaciones/digitalizar_figura.py) | Extracción de curvas desde la imagen de la figura |
| `fourier8_fig3.csv`, `pitch_fig3.csv` | Coeficientes y nodos del ajuste |
| `digitalizado_*.csv` | Puntos extraídos de la figura |
| `procedencia.json`, `validacion.json` | Fuente, método, errores y comprobaciones |
| `referencia_figura3/` | Copia de referencia de una versión del script |

## Qué está validado y qué no

<<<<<<< HEAD
=======
<<<<<<< HEAD
>>>>>>> 348622558d5b2030a604535e15bc167e44b02d49
La implementación independiente en Python comprobó que el ciclo cierra (error 0), que un yaw positivo mueve la aleta hacia +X y que la suavización de pitch no introduce saltos de velocidad.

`validacion.json` indica que **MATLAB no se ejecutó** en esa comprobación (se usó Python). Falta correr `movimiento_aletas.m` en MATLAB y confirmar que reproduce los mismos resultados.

No están validados: los desplazamientos anatómicos exactos, el tamaño absoluto, las fuerzas hidrodinámicas ni el robot real. Los coeficientes provienen de una imagen y **no son los coeficientes originales** de los autores. Además, `digitalizar_figura.py` lee `fig3_paper.png`, imagen que no está en el repositorio; para repetir la digitalización hay que descargarla desde la fuente indicada en `procedencia.json`.

## Reproducibilidad y alcance del modelo

Los archivos CSV permiten rastrear las series angulares digitalizadas y los datos de reconstrucción utilizados en las representaciones gráficas. El archivo `procedencia.json` documenta la procedencia de la referencia; `validacion.json` describe las comprobaciones realizadas y su alcance. En una evaluación posterior, conviene reportar de manera conjunta error de ajuste, continuidad entre ciclos, incertidumbre de la digitalización y sensibilidad respecto al número de armónicos, antes de usar la trayectoria como referencia experimental de control.
<<<<<<< HEAD
=======
=======
> [!LOGRO] La implementación independiente en Python comprobó que el ciclo cierra (error 0), que un yaw positivo mueve la aleta hacia +X y que la suavización de pitch no introduce saltos de velocidad.

> [!PENDIENTE] `validacion.json` indica que **MATLAB no se ejecutó** en esa comprobación (se usó Python). Falta correr `movimiento_aletas.m` en MATLAB y confirmar que reproduce los mismos resultados.

> [!AVISO] No están validados: los desplazamientos anatómicos exactos, el tamaño absoluto, las fuerzas hidrodinámicas ni el robot real. Los coeficientes provienen de una imagen y **no son los coeficientes originales** de los autores. Además, `digitalizar_figura.py` lee `fig3_paper.png`, imagen que no está en el repositorio; para repetir la digitalización hay que descargarla desde la fuente indicada en `procedencia.json`.
>>>>>>> 7becdd6392672aaff77769c75e5f0a4774b02834
>>>>>>> 348622558d5b2030a604535e15bc167e44b02d49

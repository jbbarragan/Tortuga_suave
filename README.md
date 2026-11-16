# Aletas neumáticas bioinspiradas — informe técnico

Aletas neumáticas de silicón (Ecoflex) inspiradas en la tortuga marina, con válvulas de tres posiciones accionadas por servo y control con ESP32-S3.

**Informe técnico con estilo editorial IEEE:** `index.html` (se publica en GitHub Pages y se abre en un Codespace).

## Ver el reporte

### GitHub Pages
1. En el repositorio: **Settings → Pages → Build and deployment → Source: GitHub Actions**.
2. Haz push a `main`. El flujo `.github/workflows/pages.yml` publica el sitio en `https://jbbarragan.github.io/Tortuga_suave/`.

### Codespace
**Code → Codespaces → Create codespace on main.** Al abrirse arranca `python3 serve.py` y el puerto 8000 se reenvía; el reporte se abre en la vista previa (o desde la pestaña *Ports*).

### Local
```bash
python3 serve.py 8000
# abrir http://localhost:8000
```
> No abras `index.html` con doble clic: el navegador bloquea la carga de los `.md` y los STL.

## Editar el contenido
| Qué | Dónde |
|---|---|
| Texto de cada sección | `content/*.md` |
| Orden y títulos de secciones | `content/index.json` |
| Modelos STL del visor 3D | `content/stl.json` |
| Estilos / scripts | `assets/css`, `assets/js` |

Las secciones utilizan prosa académica y anotaciones técnicas neutras. El visor STL se inserta con `<div data-stl-viewer="actuales"></div>`. Las figuras se numeran automáticamente por sección en la vista web.

## Contenido del repositorio
`STL/` molde e insertos · `cople_*` acople servo–válvula · `Aletas_ESP32S3/` firmware · `Matlab_simulaciones/` cinemática · `Fallos_aprendizajes/` evidencias · `simulacion_aletas.html` secuencia interactiva.

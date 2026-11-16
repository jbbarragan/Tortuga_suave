/* Reporte "Tortuga suave": carga content/*.md y los muestra con un router por hash.
   Para editar el texto basta con modificar los archivos .md; para agregar secciones, añade una entrada a content/index.json. */
(() => {
  const $ = (s, r = document) => r.querySelector(s);
  const main = $('#content'), toc = $('#toc'), sidebar = $('#sidebar'), menuBtn = $('#menu-btn');
  const REPO_EDIT = 'https://github.com/jbbarragan/Tortuga_suave/edit/main/content/';
  let pages = [], stlSets = {};
  const cache = {};

  const slugify = t => t.toLowerCase().normalize('NFD').replace(/[\u0300-\u036f]/g, '').replace(/[^a-z0-9]+/g, '-').replace(/(^-|-$)/g, '');

  async function getJSON(u) { const r = await fetch(u); if (!r.ok) throw new Error(u + ' → ' + r.status); return r.json(); }
  async function getText(u) { if (cache[u]) return cache[u]; const r = await fetch(u); if (!r.ok) throw new Error(u + ' → ' + r.status); return (cache[u] = await r.text()); }

  function buildToc() {
    toc.innerHTML = pages.map(p => `<li><a href="#/${p.slug}" data-slug="${p.slug}">${p.title}</a></li>`).join('');
  }

  const CALLOUTS = { NOTA: 'note', AVISO: 'warn', PENDIENTE: 'todo', LOGRO: 'ok' };
  function decorate(root) {
    // Tablas con scroll horizontal
    root.querySelectorAll('table').forEach(t => { const w = document.createElement('div'); w.className = 'table-wrap'; t.replaceWith(w); w.appendChild(t); });
    // Llamadas  > [!NOTA] Texto
    root.querySelectorAll('blockquote').forEach(bq => {
      const p = bq.querySelector('p'); if (!p) return;
      const m = p.innerHTML.match(/^\s*\[!(NOTA|AVISO|PENDIENTE|LOGRO)\]\s*/i);
      if (!m) return;
      const kind = m[1].toUpperCase();
      bq.classList.add(CALLOUTS[kind]);
      p.innerHTML = p.innerHTML.slice(m[0].length);
      const tag = document.createElement('span'); tag.className = 'tag'; tag.textContent = kind;
      bq.prepend(tag);
    });
    // Ids en encabezados
    root.querySelectorAll('h2,h3').forEach(h => { h.id = h.id || slugify(h.textContent); });
    // Enlaces externos
    root.querySelectorAll('a[href^="http"]').forEach(a => { a.target = '_blank'; a.rel = 'noopener'; });
    // Visores STL
    root.querySelectorAll('[data-stl-viewer]').forEach(el => {
      const files = stlSets[el.dataset.stlViewer];
      if (!files) { el.textContent = 'Conjunto STL no definido en content/stl.json: ' + el.dataset.stlViewer; return; }
      window.STLViewer.mount(el, files);
    });
  }

  function pager(i) {
    const prev = pages[i - 1], next = pages[i + 1];
    return `<nav class="pager" aria-label="Navegación entre secciones">
      ${prev ? `<a class="prev" href="#/${prev.slug}"><small>← Anterior</small>${prev.title}</a>` : '<span></span>'}
      ${next ? `<a class="next" href="#/${next.slug}"><small>Siguiente →</small>${next.title}</a>` : '<span></span>'}</nav>`;
  }

  async function route() {
    const hash = location.hash.replace(/^#\/?/, '');
    const [slug, anchor] = hash.split('#');
    let i = pages.findIndex(p => p.slug === (slug || 'inicio')); if (i < 0) i = 0;
    const page = pages[i];
    toc.querySelectorAll('a').forEach(a => a.classList.toggle('on', a.dataset.slug === page.slug));
    try {
      const md = await getText('content/' + page.file);
      window.STLViewer && window.STLViewer.disposeAll();
      main.innerHTML = marked.parse(md, { gfm: true }) + pager(i) +
        `<p class="edit"><a href="${REPO_EDIT}${page.file}">✎ Editar esta página en GitHub</a></p>`;
      decorate(main);
      document.title = page.title + ' · Tortuga suave';
      if (anchor) { const t = document.getElementById(anchor); t ? t.scrollIntoView() : window.scrollTo(0, 0); } else window.scrollTo(0, 0);
    } catch (e) {
      main.innerHTML = `<h1>No se pudo cargar la página</h1><p>${e.message}</p><p>Si abriste <code>index.html</code> con doble clic, el navegador bloquea la carga de archivos. Sirve la carpeta con <code>python3 serve.py</code> (o usa el Codespace / GitHub Pages).</p>`;
    }
    sidebar.classList.remove('open'); menuBtn.setAttribute('aria-expanded', 'false');
  }

  menuBtn.addEventListener('click', () => { const o = sidebar.classList.toggle('open'); menuBtn.setAttribute('aria-expanded', o); });
  addEventListener('hashchange', route);

  (async () => {
    try {
      [pages, stlSets] = await Promise.all([getJSON('content/index.json'), getJSON('content/stl.json')]);
      buildToc(); route();
    } catch (e) {
      main.innerHTML = `<h1>Error al iniciar</h1><p>${e.message}</p><p>Sirve la carpeta por HTTP: <code>python3 serve.py</code>.</p>`;
    }
  })();
})();

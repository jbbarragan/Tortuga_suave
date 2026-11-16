/* Visor STL sin dependencias externas (three.js r128 local). Convención CAD: Z hacia arriba. */
window.STLViewer = (() => {
  const live = new Set();
  const loader = new THREE.STLLoader();
  const geomCache = {};

  function load(path) {
    if (!geomCache[path]) geomCache[path] = new Promise((res, rej) => loader.load(path, g => {
      g.computeBoundingBox();
      const pos = g.attributes.position, n = pos.count / 3; let vol = 0;
      const a = new THREE.Vector3(), b = new THREE.Vector3(), c = new THREE.Vector3();
      for (let i = 0; i < pos.count; i += 3) { a.fromBufferAttribute(pos, i); b.fromBufferAttribute(pos, i + 1); c.fromBufferAttribute(pos, i + 2); vol += a.dot(b.clone().cross(c)) / 6; }
      res({ geom: g, tris: n, vol: Math.abs(vol), box: g.boundingBox.clone() });
    }, undefined, () => rej(new Error('No se pudo cargar ' + path))));
    return geomCache[path];
  }

  function mount(el, files) {
    el.classList.add('stl-viewer');
    el.innerHTML = `
      <div class="stl-canvas"><div class="stl-status">Cargando modelos…</div><span class="stl-hint">Arrastra para girar · rueda para zoom · clic derecho para mover</span></div>
      <div class="stl-panel">
        <div><h5>Modelos</h5><div class="stl-files"></div></div>
        <div><h5>Vista</h5>
          <div class="stl-opts">
            <label><input type="checkbox" data-o="wire"> Malla</label>
            <label><input type="checkbox" data-o="alpha"> Semitransparente</label>
            <label><input type="checkbox" data-o="spin"> Girar</label>
            <label><input type="checkbox" data-o="axes" checked> Ejes</label>
          </div>
          <button type="button" data-o="reset">Restablecer vista</button>
          <div class="stl-info" aria-live="polite"></div>
        </div>
      </div>`;
    const host = el.querySelector('.stl-canvas'), status = el.querySelector('.stl-status'), info = el.querySelector('.stl-info');
    const scene = new THREE.Scene();
    const camera = new THREE.PerspectiveCamera(40, 1, 0.1, 5000); camera.up.set(0, 0, 1);
    const renderer = new THREE.WebGLRenderer({ antialias: true, alpha: true });
    renderer.setPixelRatio(Math.min(devicePixelRatio, 2)); host.prepend(renderer.domElement);
    scene.add(new THREE.HemisphereLight(0xdff3ff, 0x1a2b3c, 0.9));
    const key = new THREE.DirectionalLight(0xffffff, 0.9); key.position.set(1, -1.2, 2); scene.add(key);
    const fill = new THREE.DirectionalLight(0x88aacc, 0.4); fill.position.set(-1, 1, -0.5); scene.add(fill);
    const controls = new THREE.OrbitControls(camera, renderer.domElement); controls.enableDamping = true; controls.autoRotateSpeed = 1.6;
    const axes = new THREE.AxesHelper(30); scene.add(axes);
    let grid = null;
    const items = files.map(f => ({ f, mesh: null, data: null }));

    const filesBox = el.querySelector('.stl-files');
    items.forEach((it, i) => {
      const l = document.createElement('label');
      l.innerHTML = `<input type="checkbox" ${it.f.on ? 'checked' : ''} data-i="${i}"><span class="sw" style="background:${it.f.color}"></span>${it.f.label}${it.f.note ? `<small>${it.f.note}</small>` : ''}`;
      l.querySelector('small') && (l.style.flexWrap = 'wrap');
      filesBox.appendChild(l);
    });

    const visibleBox = () => { const b = new THREE.Box3(); items.forEach((it, i) => { if (it.mesh && it.mesh.visible) b.union(it.data.box); }); return b; };
    function fit() {
      const b = visibleBox(); if (b.isEmpty()) return;
      const c = b.getCenter(new THREE.Vector3()), s = b.getSize(new THREE.Vector3()), r = Math.max(s.x, s.y, s.z) * 0.5 || 10;
      const d = r / Math.tan(THREE.MathUtils.degToRad(camera.fov / 2)) * 1.25;
      camera.position.set(c.x + d * 0.75, c.y - d * 0.85, c.z + d * 0.55);
      controls.target.copy(c); controls.update();
      axes.scale.setScalar(Math.max(r / 25, 0.4)); axes.position.set(b.min.x, b.min.y, b.min.z);
      if (grid) scene.remove(grid);
      const size = Math.ceil(r * 3 / 10) * 10; grid = new THREE.GridHelper(size, size / 10, 0x3b5873, 0x203548); grid.rotation.x = Math.PI / 2; grid.position.set(c.x, c.y, b.min.z - 0.05); scene.add(grid);
    }
    function refreshInfo() {
      const lines = items.filter(it => it.mesh && it.mesh.visible).map(it => {
        const s = it.data.box.getSize(new THREE.Vector3());
        return `<b>${it.f.label}</b><br>${s.x.toFixed(1)} × ${s.y.toFixed(1)} × ${s.z.toFixed(1)} mm · ${it.data.tris.toLocaleString('es-MX')} triángulos · ${(it.data.vol / 1000).toFixed(1)} cm³`;
      });
      info.innerHTML = lines.join('<br>') || 'Selecciona un modelo.';
    }
    function style() {
      const wire = el.querySelector('[data-o=wire]').checked, alpha = el.querySelector('[data-o=alpha]').checked;
      items.forEach(it => { if (!it.mesh) return; const m = it.mesh.material; m.wireframe = wire; m.transparent = alpha; m.opacity = alpha ? 0.5 : 1; m.depthWrite = !alpha; m.needsUpdate = true; });
    }

    Promise.all(items.map(async it => {
      it.data = await load(it.f.path);
      it.mesh = new THREE.Mesh(it.data.geom, new THREE.MeshStandardMaterial({ color: it.f.color, roughness: 0.55, metalness: 0.05, side: THREE.DoubleSide }));
      it.mesh.visible = !!it.f.on; scene.add(it.mesh);
    })).then(() => { status.remove(); style(); fit(); refreshInfo(); })
      .catch(e => { status.textContent = e.message + ' (¿abriste con doble clic? sirve la carpeta por HTTP)'; });

    el.addEventListener('change', e => {
      const t = e.target;
      if (t.dataset.i !== undefined) { const it = items[+t.dataset.i]; if (it.mesh) { it.mesh.visible = t.checked; fit(); refreshInfo(); } }
      else if (t.dataset.o === 'wire' || t.dataset.o === 'alpha') style();
      else if (t.dataset.o === 'spin') controls.autoRotate = t.checked;
      else if (t.dataset.o === 'axes') axes.visible = t.checked;
    });
    el.querySelector('[data-o=reset]').addEventListener('click', fit);

    const resize = () => { const w = host.clientWidth, h = host.clientHeight; if (!w || !h) return; renderer.setSize(w, h, false); camera.aspect = w / h; camera.updateProjectionMatrix(); };
    const ro = new ResizeObserver(resize); ro.observe(host); resize();
    let raf = 0;
    const inst = { dispose() { cancelAnimationFrame(raf); ro.disconnect(); renderer.dispose(); live.delete(inst); } };
    (function loop() { if (!el.isConnected) return inst.dispose(); raf = requestAnimationFrame(loop); controls.update(); renderer.render(scene, camera); })();
    live.add(inst);
  }
  return { mount, disposeAll() { [...live].forEach(i => i.dispose()); } };
})();

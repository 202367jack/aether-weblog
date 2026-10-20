(function () {
  var reduce = window.matchMedia('(prefers-reduced-motion: reduce)').matches;
  var fine = window.matchMedia('(hover: hover) and (pointer: fine)').matches;
  if (reduce || !fine) return;

  /* ---------- 鼠标跟随光斑 ---------- */

  var glow = document.getElementById('cursor-glow');
  if (glow) {
    var gx = 0, gy = 0, cx = 0, cy = 0, glowing = false;

    window.addEventListener('pointermove', function (e) {
      gx = e.clientX;
      gy = e.clientY;
      if (!glowing) {
        glowing = true;
        cx = gx;
        cy = gy;
        glow.classList.add('on');
        requestAnimationFrame(loop);
      }
    }, { passive: true });

    document.addEventListener('pointerleave', function () {
      glowing = false;
      glow.classList.remove('on');
    });

    function loop() {
      if (!glowing) return;
      cx += (gx - cx) * 0.14;
      cy += (gy - cy) * 0.14;
      glow.style.transform = 'translate3d(' + cx + 'px,' + cy + 'px,0)';
      requestAnimationFrame(loop);
    }
  }

  /* ---------- 卡片 3D 倾斜 ---------- */

  var MAX_X = 7;
  var MAX_Y = 10;

  function reset(el) {
    el.style.setProperty('--rx', '0deg');
    el.style.setProperty('--ry', '0deg');
    el.style.setProperty('--mx', '50%');
    el.style.setProperty('--my', '50%');
  }

  var cards = document.querySelectorAll('.card, .poster-card');
  Array.prototype.forEach.call(cards, function (el) {
    el.classList.add('tilt');
    reset(el);

    el.addEventListener('pointermove', function (e) {
      var r = el.getBoundingClientRect();
      if (!r.width || !r.height) return;
      var px = (e.clientX - r.left) / r.width;
      var py = (e.clientY - r.top) / r.height;
      el.style.setProperty('--rx', ((0.5 - py) * MAX_X).toFixed(2) + 'deg');
      el.style.setProperty('--ry', ((px - 0.5) * MAX_Y).toFixed(2) + 'deg');
      el.style.setProperty('--mx', (px * 100).toFixed(1) + '%');
      el.style.setProperty('--my', (py * 100).toFixed(1) + '%');
    }, { passive: true });

    el.addEventListener('pointerleave', function () { reset(el); });
  });
})();

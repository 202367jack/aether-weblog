(function () {
  var input = document.getElementById('search-input');
  var box = document.getElementById('search-results');
  if (!input || !box) return;

  var indexUrl = box.getAttribute('data-index');
  var pages = null;
  var lastHits = [];

  var LABELS = {
    posts: '笔记',
    projects: '项目',
    media: '影视',
    about: '关于',
    resume: '简历'
  };

  function escapeHtml(s) {
    return String(s).replace(/[&<>"']/g, function (c) {
      return { '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;' }[c];
    });
  }

  function snippet(text, q) {
    if (!text) return '';
    var lower = text.toLowerCase();
    var i = lower.indexOf(q);
    if (i < 0) return text.slice(0, 90);
    var start = Math.max(0, i - 30);
    var end = Math.min(text.length, i + q.length + 70);
    return (start > 0 ? '…' : '') + text.slice(start, end) + (end < text.length ? '…' : '');
  }

  function hide() {
    box.hidden = true;
    box.innerHTML = '';
    lastHits = [];
  }

  function render(q) {
    q = (q || '').trim().toLowerCase();
    if (!q) { hide(); return; }
    if (!pages) return;

    var hits = pages.filter(function (p) {
      var hay = [p.title, p.summary, p.content, (p.tags || []).join(' ')].join(' ').toLowerCase();
      return hay.indexOf(q) >= 0;
    });
    lastHits = hits;

    if (!hits.length) {
      box.innerHTML = '<p class="hint">没有找到「' + escapeHtml(q) + '」相关内容。</p>';
      box.hidden = false;
      return;
    }

    var html = '<p class="hint">找到 ' + hits.length + ' 条</p><ul class="entry-list">';
    hits.slice(0, 8).forEach(function (p) {
      html += '<li>' +
        '<a href="' + p.url + '">' + escapeHtml(p.title) + '</a>' +
        '<span class="badge">' + escapeHtml(LABELS[p.section] || p.section) + '</span>' +
        '<p class="snippet">' + escapeHtml(snippet(p.summary || p.content, q)) + '</p>' +
        '</li>';
    });
    html += '</ul>';
    if (hits.length > 8) {
      html += '<p class="hint">只显示前 8 条，输入更多关键词可缩小范围。</p>';
    }
    box.innerHTML = html;
    box.hidden = false;
  }

  fetch(indexUrl)
    .then(function (r) { return r.json(); })
    .then(function (data) {
      pages = data;
      input.addEventListener('input', function () { render(input.value); });
    })
    .catch(function () {
      box.innerHTML = '<p class="hint">搜索索引加载失败，请刷新重试。</p>';
      box.hidden = false;
    });

  input.addEventListener('keydown', function (e) {
    if (e.key === 'Enter') {
      e.preventDefault();
      if (lastHits.length) window.location.href = lastHits[0].url;
    } else if (e.key === 'Escape') {
      input.value = '';
      hide();
    }
  });

  document.addEventListener('click', function (e) {
    if (!box.hidden && !box.contains(e.target) && e.target !== input) hide();
  });

  input.addEventListener('focus', function () {
    if (input.value.trim()) render(input.value);
  });
})();

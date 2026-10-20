(function () {
  var input = document.getElementById('search-input');
  var box = document.getElementById('search-results');
  if (!input || !box) return;

  var indexUrl = box.getAttribute('data-index');
  var pages = null;

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
    if (i < 0) return text.slice(0, 110);
    var start = Math.max(0, i - 40);
    var end = Math.min(text.length, i + q.length + 80);
    return (start > 0 ? '…' : '') + text.slice(start, end) + (end < text.length ? '…' : '');
  }

  function render(q) {
    q = (q || '').trim().toLowerCase();
    if (!q) {
      box.innerHTML = '<p class="hint">输入关键词开始搜索，例如「Docker」「悬疑」。</p>';
      return;
    }
    var hits = pages.filter(function (p) {
      var hay = [p.title, p.summary, p.content, (p.tags || []).join(' ')].join(' ').toLowerCase();
      return hay.indexOf(q) >= 0;
    });

    if (!hits.length) {
      box.innerHTML = '<p class="hint">没有找到「' + escapeHtml(q) + '」相关的内容。</p>';
      return;
    }

    var html = '<p class="hint">找到 ' + hits.length + ' 条结果</p><ul class="entry-list">';
    hits.forEach(function (p) {
      html += '<li>' +
        '<a href="' + p.url + '">' + escapeHtml(p.title) + '</a>' +
        '<span class="badge">' + escapeHtml(LABELS[p.section] || p.section) + '</span>' +
        '<p class="snippet">' + escapeHtml(snippet(p.summary || p.content, q)) + '</p>' +
        '</li>';
    });
    html += '</ul>';
    box.innerHTML = html;
  }

  fetch(indexUrl)
    .then(function (r) { return r.json(); })
    .then(function (data) {
      pages = data;
      render(input.value);
      input.addEventListener('input', function () { render(input.value); });
    })
    .catch(function () {
      box.innerHTML = '<p class="hint">搜索索引加载失败，请刷新重试。</p>';
    });
})();

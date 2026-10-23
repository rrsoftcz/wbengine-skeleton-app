{* Live demo: a console for the REST API of this application. *}
<section class="mt-6 rounded-2xl border border-indigo-200 bg-indigo-50/60 p-6 lg:ml-[17rem]" aria-labelledby="demo-api">
    <p class="eyebrow py-0">{t 'demo.live'}</p>
    <h2 id="demo-api" class="mb-1 mt-1 text-xl">{t 'demo.api.title'}</h2>
    <p class="py-0 text-sm text-slate-600">{t 'demo.api.lead'}</p>

    <form id="api-login" class="mt-4 grid grid-cols-1 gap-3 sm:grid-cols-3" autocomplete="off">
        <input type="text" id="api-user" value="admin@example.com" aria-label="E-mail">
        <input type="password" id="api-pass" value="changeme" aria-label="{t 'wb.login.password'}">
        <button type="submit" class="btn-primary">POST /api/auth/login</button>
    </form>
    <div class="mt-3 hidden flex-wrap gap-2" id="api-calls">
        <button type="button" class="btn-outline" data-call="GET /api/translations/article/1">GET /api/translations/article/1</button>
        <button type="button" class="btn-outline" data-call="GET /api/users">GET /api/users</button>
        <button type="button" class="btn-outline" data-call="GET /api/sections">GET /api/sections</button>
        <button type="button" class="btn-outline" data-call="POST /api/cache/flush">POST /api/cache/flush</button>
    </div>
    <pre id="api-out" class="mt-4 max-h-80 overflow-auto rounded-xl bg-slate-900 p-4 font-mono text-xs leading-5 text-slate-100">{t 'demo.api.idle'}</pre>
    <script>
        (function () {
            var token = null, out = document.getElementById('api-out');
            function show(status, body) { out.textContent = status + '\n' + body; }
            document.getElementById('api-login').addEventListener('submit', function (e) {
                e.preventDefault();
                fetch('/api/auth/login', { method: 'POST', headers: { 'Content-Type': 'application/json' }, credentials: 'same-origin',
                    body: JSON.stringify({ username: document.getElementById('api-user').value, password: document.getElementById('api-pass').value }) })
                    .then(function (r) { return r.json().then(function (j) { return [r.status, j]; }); })
                    .then(function (a) {
                        token = a[1] && a[1].token ? a[1].token : null;
                        if (token) { a[1].token = token.slice(0, 24) + '...'; }
                        show('HTTP ' + a[0], JSON.stringify(a[1], null, 2));
                        var calls = document.getElementById('api-calls'); calls.classList.toggle('hidden', !token); calls.classList.toggle('flex', !!token);
                    });
            });
            document.querySelectorAll('[data-call]').forEach(function (b) {
                b.addEventListener('click', function () {
                    var p = b.getAttribute('data-call').split(' ');
                    fetch(p[1], { method: p[0], headers: { 'Authorization': 'Bearer ' + token } })
                        .then(function (r) { return r.text().then(function (t) { show('HTTP ' + r.status, t); }); });
                });
            });
        })();
    </script>
</section>

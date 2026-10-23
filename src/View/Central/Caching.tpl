{* Live demo: when this page was built and what it cost. With the page cache the time does not change on reload. *}
<section class="mt-6 rounded-2xl border border-indigo-200 bg-indigo-50/60 p-6 lg:ml-[17rem]" aria-labelledby="demo-cache">
    <p class="eyebrow py-0">{t 'demo.live'}</p>
    <h2 id="demo-cache" class="mb-1 mt-1 text-xl">{t 'demo.cache.title'}</h2>
    <p class="py-0 text-sm text-slate-600">{t 'demo.cache.lead'}</p>

    <div class="mt-4 grid grid-cols-1 gap-4 sm:grid-cols-3">
        <div class="rounded-xl border border-slate-200 bg-white p-4"><div class="text-xs uppercase tracking-wider text-slate-500">{t 'demo.cache.built'}</div><div class="mt-1 font-mono text-2xl font-bold text-slate-900">{$Caching.built}</div></div>
        <div class="rounded-xl border border-slate-200 bg-white p-4"><div class="text-xs uppercase tracking-wider text-slate-500">{t 'demo.cache.queries'}</div><div class="mt-1 font-mono text-2xl font-bold text-slate-900">{$Caching.queries}</div></div>
        <div class="rounded-xl border border-slate-200 bg-white p-4"><div class="text-xs uppercase tracking-wider text-slate-500">{t 'demo.cache.time'}</div><div class="mt-1 font-mono text-2xl font-bold text-slate-900">{$Caching.ms} ms</div></div>
    </div>

    <ul class="mt-4 flex flex-wrap gap-2 p-0 text-xs">
        <li class="chip list-none">{t 'demo.cache.data'}: {if $Caching.dataCache}{$Caching.driver}{else}{t 'demo.off'}{/if}</li>
        <li class="chip list-none">{t 'demo.cache.pages'}: {if $Caching.pageCache}{t 'demo.on'}, {$Caching.ttl} s{else}{t 'demo.off'}{/if}</li>
    </ul>

    <div class="mt-4 flex flex-wrap items-center gap-3 rounded-xl border border-slate-200 bg-white p-4 text-sm">
        <button type="button" id="cache-probe" class="btn-primary">{t 'demo.cache.reload'}</button>
        <span>X-WBengine-Cache: <code id="cache-status" class="rounded bg-slate-100 px-2 py-0.5 font-mono">-</code></span>
        <span class="text-xs text-slate-500">{t 'demo.cache.hint'}</span>
    </div>
    <script>
        document.getElementById('cache-probe').addEventListener('click', function () {
            fetch(location.href, { method: 'GET', cache: 'no-store', credentials: 'same-origin' }).then(function (r) {
                document.getElementById('cache-status').textContent = r.headers.get('X-WBengine-Cache') || '-';
                return r.text();
            }).then(function (html) {
                var m = html.match(/font-mono text-2xl font-bold text-slate-900">(\d\d:\d\d:\d\d)</);
                if (m) { document.getElementById('cache-status').textContent += '  (' + m[1] + ')'; }
            });
        });
    </script>
</section>

{* The feature overview of the home page: a static box (cms_boxes: staticBoxes / features, site 1). *}
<section class="pt-16" aria-labelledby="features-title">
    <div class="mx-auto max-w-2xl text-center">
        <p class="eyebrow py-0">{t 'feat.eyebrow'}</p>
        <h2 id="features-title" class="mb-0 mt-2 text-3xl sm:text-4xl">{t 'feat.title'}</h2>
        <p class="lead mt-4 py-0">{t 'feat.lead'}</p>
    </div>

    <div class="mt-12 grid grid-cols-1 gap-5 sm:grid-cols-2 lg:grid-cols-4">
        <a class="card group" href="{'/docs/architecture/'|lurl}">
            <span class="mb-4 grid h-11 w-11 place-items-center rounded-xl bg-indigo-50 text-indigo-600 group-hover:bg-indigo-600 group-hover:text-white"><svg class="h-6 w-6" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="1.8"><path stroke-linecap="round" stroke-linejoin="round" d="M3 7l9-4 9 4-9 4-9-4zm0 5l9 4 9-4M3 17l9 4 9-4"/></svg></span>
            <h3 class="m-0 text-lg">{t 'feat.arch.title'}</h3>
            <p class="mt-2 py-0 text-sm text-slate-600">{t 'feat.arch.text'}</p>
        </a>
        <a class="card group" href="{'/docs/boxes/'|lurl}">
            <span class="mb-4 grid h-11 w-11 place-items-center rounded-xl bg-violet-50 text-violet-600 group-hover:bg-violet-600 group-hover:text-white"><svg class="h-6 w-6" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="1.8"><path stroke-linecap="round" stroke-linejoin="round" d="M4 5h7v7H4zM13 5h7v7h-7zM4 14h7v5H4zM13 14h7v5h-7z"/></svg></span>
            <h3 class="m-0 text-lg">{t 'feat.boxes.title'}</h3>
            <p class="mt-2 py-0 text-sm text-slate-600">{t 'feat.boxes.text'}</p>
        </a>
        <a class="card group" href="{'/docs/templates/'|lurl}">
            <span class="mb-4 grid h-11 w-11 place-items-center rounded-xl bg-fuchsia-50 text-fuchsia-600 group-hover:bg-fuchsia-600 group-hover:text-white"><svg class="h-6 w-6" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="1.8"><path stroke-linecap="round" stroke-linejoin="round" d="M8 9l-4 3 4 3m8-6l4 3-4 3M14 5l-4 14"/></svg></span>
            <h3 class="m-0 text-lg">{t 'feat.tpl.title'}</h3>
            <p class="mt-2 py-0 text-sm text-slate-600">{t 'feat.tpl.text'}</p>
        </a>
        <a class="card group" href="{'/docs/languages/'|lurl}">
            <span class="mb-4 grid h-11 w-11 place-items-center rounded-xl bg-sky-50 text-sky-600 group-hover:bg-sky-600 group-hover:text-white"><svg class="h-6 w-6" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="1.8"><path stroke-linecap="round" stroke-linejoin="round" d="M12 21a9 9 0 100-18 9 9 0 000 18zM3.6 9h16.8M3.6 15h16.8M12 3c2.5 2.6 3.8 5.6 3.8 9s-1.3 6.4-3.8 9c-2.5-2.6-3.8-5.6-3.8-9S9.5 5.6 12 3z"/></svg></span>
            <h3 class="m-0 text-lg">{t 'feat.i18n.title'}</h3>
            <p class="mt-2 py-0 text-sm text-slate-600">{t 'feat.i18n.text'}</p>
        </a>
        <a class="card group" href="{'/docs/caching/'|lurl}">
            <span class="mb-4 grid h-11 w-11 place-items-center rounded-xl bg-amber-50 text-amber-600 group-hover:bg-amber-500 group-hover:text-white"><svg class="h-6 w-6" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="1.8"><path stroke-linecap="round" stroke-linejoin="round" d="M13 10V3L4 14h7v7l9-11h-7z"/></svg></span>
            <h3 class="m-0 text-lg">{t 'feat.cache.title'}</h3>
            <p class="mt-2 py-0 text-sm text-slate-600">{t 'feat.cache.text'}</p>
        </a>
        <a class="card group" href="{'/docs/security/'|lurl}">
            <span class="mb-4 grid h-11 w-11 place-items-center rounded-xl bg-emerald-50 text-emerald-600 group-hover:bg-emerald-600 group-hover:text-white"><svg class="h-6 w-6" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="1.8"><path stroke-linecap="round" stroke-linejoin="round" d="M12 3l8 3v6c0 4.5-3.2 8-8 9-4.8-1-8-4.5-8-9V6l8-3zm-3 9l2 2 4-4"/></svg></span>
            <h3 class="m-0 text-lg">{t 'feat.sec.title'}</h3>
            <p class="mt-2 py-0 text-sm text-slate-600">{t 'feat.sec.text'}</p>
        </a>
        <a class="card group" href="{'/docs/rest-api/'|lurl}">
            <span class="mb-4 grid h-11 w-11 place-items-center rounded-xl bg-rose-50 text-rose-600 group-hover:bg-rose-600 group-hover:text-white"><svg class="h-6 w-6" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="1.8"><path stroke-linecap="round" stroke-linejoin="round" d="M5 12h14M12 5l7 7-7 7"/></svg></span>
            <h3 class="m-0 text-lg">{t 'feat.api.title'}</h3>
            <p class="mt-2 py-0 text-sm text-slate-600">{t 'feat.api.text'}</p>
        </a>
        <a class="card group" href="{'/docs/administration/'|lurl}">
            <span class="mb-4 grid h-11 w-11 place-items-center rounded-xl bg-emerald-50 text-emerald-700 group-hover:bg-emerald-600 group-hover:text-white"><svg class="h-6 w-6" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="1.8"><path stroke-linecap="round" stroke-linejoin="round" d="M4 7h16M4 12h16M4 17h16M8 4v16m8-16v16"/></svg></span>
            <h3 class="m-0 text-lg">{t 'feat.admin.title'}</h3>
            <p class="mt-2 py-0 text-sm text-slate-600">{t 'feat.admin.text'}</p>
        </a>
        <a class="card group" href="{'/blog/'|lurl}">
            <span class="mb-4 grid h-11 w-11 place-items-center rounded-xl bg-slate-100 text-slate-700 group-hover:bg-slate-800 group-hover:text-white"><svg class="h-6 w-6" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="1.8"><path stroke-linecap="round" stroke-linejoin="round" d="M19 20H5a2 2 0 01-2-2V6a2 2 0 012-2h9l5 5v9a2 2 0 01-2 2zM9 13h6M9 17h6"/></svg></span>
            <h3 class="m-0 text-lg">{t 'feat.blog.title'}</h3>
            <p class="mt-2 py-0 text-sm text-slate-600">{t 'feat.blog.text'}</p>
        </a>
    </div>

    <div class="mt-20 grid grid-cols-1 items-start gap-10 lg:grid-cols-5">
        <div class="lg:col-span-2">
            <p class="eyebrow py-0">{t 'flow.eyebrow'}</p>
            <h2 class="mb-0 mt-2 text-3xl">{t 'flow.title'}</h2>
            <p class="lead mt-4 py-0">{t 'flow.lead'}</p>
        </div>
        <ol class="m-0 grid grid-cols-1 list-none gap-4 p-0 sm:grid-cols-2 lg:col-span-3">
            <li class="card"><span class="chip">1</span><h3 class="mb-0 mt-3 text-base">{t 'flow.1.title'}</h3><p class="mt-1 py-0 text-sm text-slate-600">{t 'flow.1.text'}</p></li>
            <li class="card"><span class="chip">2</span><h3 class="mb-0 mt-3 text-base">{t 'flow.2.title'}</h3><p class="mt-1 py-0 text-sm text-slate-600">{t 'flow.2.text'}</p></li>
            <li class="card"><span class="chip">3</span><h3 class="mb-0 mt-3 text-base">{t 'flow.3.title'}</h3><p class="mt-1 py-0 text-sm text-slate-600">{t 'flow.3.text'}</p></li>
            <li class="card"><span class="chip">4</span><h3 class="mb-0 mt-3 text-base">{t 'flow.4.title'}</h3><p class="mt-1 py-0 text-sm text-slate-600">{t 'flow.4.text'}</p></li>
        </ol>
    </div>

    <div class="relative mt-20 overflow-hidden rounded-3xl bg-slate-950 p-10 text-center text-slate-200 shadow-xl sm:p-14">
        <div class="pointer-events-none absolute inset-0 opacity-70" aria-hidden="true"
             style="background: radial-gradient(60% 80% at 80% 0%, rgba(99,102,241,.55) 0, transparent 60%), radial-gradient(50% 70% at 0% 100%, rgba(217,70,239,.35) 0, transparent 60%);"></div>
        <div class="relative">
            <h2 class="m-0 text-3xl text-white">{t 'cta.title'}</h2>
            <p class="mx-auto mt-3 max-w-xl py-0 text-slate-300">{t 'cta.text'}</p>
            <pre class="mx-auto mt-6 max-w-xl overflow-x-auto rounded-xl border border-white/10 bg-slate-900/80 p-4 text-left font-mono text-sm text-slate-200 shadow-2xl ring-1 ring-black/40 backdrop-blur"><code>git clone https://github.com/rrsoftcz/wbengine-skeleton-app
docker compose up -d --build</code></pre>
            <div class="mt-6 flex flex-wrap justify-center gap-3">
                <a class="btn-white" href="{'/docs/'|lurl}">{t 'hero.cta_start'}</a>
                <a class="btn-ghost" href="https://github.com/rrsoftcz/wbengine-skeleton-app">{t 'jumbotron.download'}</a>
            </div>
        </div>
    </div>
</section>

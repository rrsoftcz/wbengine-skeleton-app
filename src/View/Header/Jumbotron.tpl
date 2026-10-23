{* The hero of the home page: a header-section box (cms_boxes: Jumbotron, section "header", site 1). *}
<section class="relative overflow-hidden bg-slate-950 text-slate-200">
    <div class="pointer-events-none absolute inset-0 opacity-70" aria-hidden="true"
         style="background: radial-gradient(60% 80% at 80% 0%, rgba(99,102,241,.55) 0, transparent 60%), radial-gradient(50% 70% at 0% 100%, rgba(217,70,239,.35) 0, transparent 60%);"></div>
    <div class="container-page relative grid grid-cols-1 items-center gap-12 py-16 lg:grid-cols-2 lg:py-24">
        <div class="min-w-0">
            <span class="inline-flex max-w-full items-center gap-2 rounded-full border border-white/15 bg-white/10 px-3 py-1 text-xs font-medium text-indigo-100">
                <span class="h-1.5 w-1.5 rounded-full bg-emerald-400"></span>{t 'hero.badge'}
            </span>
            <h1 class="mb-0 mt-6 text-4xl font-extrabold leading-tight text-white sm:text-5xl">
                {t 'hero.title_a'}<br><span class="bg-gradient-to-r from-indigo-300 via-violet-300 to-fuchsia-300 bg-clip-text text-transparent">{t 'hero.title_b'}</span>
            </h1>
            <p class="mt-6 max-w-xl py-0 text-lg leading-8 text-slate-300">{t 'hero.lead'}</p>
            <div class="mt-8 flex flex-wrap gap-3">
                <a class="btn-white" href="{'/docs/'|lurl}">{t 'hero.cta_start'}</a>
                <a class="btn-ghost" href="{'/docs/architecture/'|lurl}">{t 'hero.cta_how'}</a>
                <a class="btn-ghost" href="https://github.com/rrsoftcz/wbengine">GitHub</a>
            </div>
            <dl class="mt-10 grid max-w-xl grid-cols-2 gap-6 sm:grid-cols-4">
                <div><dt class="text-xs uppercase tracking-wider text-slate-400">{t 'hero.stat_php'}</dt><dd class="m-0 text-xl font-bold text-white">8.3 &ndash; 8.5</dd></div>
                <div><dt class="text-xs uppercase tracking-wider text-slate-400">{t 'hero.stat_tests'}</dt><dd class="m-0 text-xl font-bold text-white">778</dd></div>
                <div><dt class="text-xs uppercase tracking-wider text-slate-400">{t 'hero.stat_cached'}</dt><dd class="m-0 text-xl font-bold text-white">0 SQL</dd></div>
                <div><dt class="text-xs uppercase tracking-wider text-slate-400">{t 'hero.stat_license'}</dt><dd class="m-0 text-xl font-bold text-white">MIT</dd></div>
            </dl>
        </div>

        <div class="relative min-w-0">
            <div class="overflow-hidden rounded-2xl border border-white/10 bg-slate-900/80 shadow-2xl ring-1 ring-black/40 backdrop-blur">
                <div class="flex items-center gap-2 border-b border-white/10 px-4 py-3">
                    <span class="h-3 w-3 rounded-full bg-rose-400/80"></span><span class="h-3 w-3 rounded-full bg-amber-400/80"></span><span class="h-3 w-3 rounded-full bg-emerald-400/80"></span>
                    <span class="ml-3 font-mono text-xs text-slate-400">src/Box/Central/Hello.php</span>
                </div>
<pre class="m-0 overflow-x-auto p-5 font-mono text-[13px] leading-6 text-slate-200"><code><span class="text-fuchsia-300">class</span> Hello <span class="text-fuchsia-300">extends</span> WbengineBoxAbstract
{
    <span class="text-fuchsia-300">public function</span> <span class="text-sky-300">Hello</span>()
    {
        <span class="text-slate-500">// a row in cms_boxes points here</span>
        <span class="text-fuchsia-300">return</span> $this-&gt;<span class="text-sky-300">getRenderer</span>()-&gt;<span class="text-sky-300">render</span>(
            $this-&gt;<span class="text-sky-300">getBoxTemplatePath</span>(),
            [<span class="text-emerald-300">'name'</span> =&gt; <span class="text-emerald-300">'World'</span>]
        );
    }
}</code></pre>
                <div class="border-t border-white/10 bg-black/30 px-5 py-3 font-mono text-xs text-emerald-300">{literal}&lt;h1&gt;{t 'hello' name=$name}&lt;/h1&gt;{/literal}</div>
            </div>
        </div>
    </div>
</section>

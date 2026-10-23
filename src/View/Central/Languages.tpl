{* Live demo: the language of this request, plural forms, numbers and dates. *}
<section class="mt-6 rounded-2xl border border-indigo-200 bg-indigo-50/60 p-6 lg:ml-[17rem]" aria-labelledby="demo-lang">
    <p class="eyebrow py-0">{t 'demo.live'}</p>
    <h2 id="demo-lang" class="mb-1 mt-1 text-xl">{t 'demo.lang.title'}</h2>
    <p class="py-0 text-sm text-slate-600">{t 'demo.lang.lead'}</p>

    <div class="mt-4 grid grid-cols-1 gap-4 md:grid-cols-2">
        <div class="min-w-0 rounded-xl border border-slate-200 bg-white p-4">
            <h3 class="mb-2 mt-0 text-sm">{t 'demo.lang.detected'}</h3>
            <dl class="m-0 grid grid-cols-[auto_1fr] gap-x-4 gap-y-1 text-sm">
                <dt class="text-slate-500">{t 'demo.lang.locale'}</dt><dd class="m-0 font-mono">{$Languages.locale}</dd>
                <dt class="text-slate-500">{t 'demo.lang.cookie'}</dt><dd class="m-0 break-all font-mono">{$Languages.cookie|default:'-'}</dd>
                <dt class="text-slate-500">Accept-Language</dt><dd class="m-0 break-all font-mono text-xs">{$Languages.accept|default:'-'}</dd>
            </dl>
            <p class="py-0 pt-3 text-xs text-slate-500">{t 'demo.lang.order'}</p>
            <p class="py-0 pt-2 text-sm">
                {foreach $Languages.locales as $l}<a class="btn-outline mr-2 mt-1" href="{$l.url}" hreflang="{$l.code}">{$l.code|upper}: {$l.url}</a>{/foreach}
            </p>
        </div>

        <div class="min-w-0 rounded-xl border border-slate-200 bg-white p-4">
            <h3 class="mb-2 mt-0 text-sm">{t 'demo.lang.plurals'}</h3>
            <ul class="m-0 list-none space-y-1 p-0 text-sm">
                {foreach $Languages.counts as $c}
                <li><span class="inline-block w-10 font-mono text-slate-500">{$c}</span> {t 'demo.files' count=$c}</li>
                {/foreach}
            </ul>
        </div>

        <div class="rounded-xl border border-slate-200 bg-white p-4 md:col-span-2">
            <h3 class="mb-2 mt-0 text-sm">{t 'demo.lang.format'}</h3>
            <dl class="m-0 grid grid-cols-1 gap-x-6 gap-y-2 text-sm sm:grid-cols-2">
                <div><dt class="font-mono text-xs text-slate-500">{literal}{$price|number:2}{/literal}</dt><dd class="m-0 font-semibold">{$Languages.price|number:2}</dd></div>
                <div><dt class="font-mono text-xs text-slate-500">{literal}{$time|ldate:'long'}{/literal}</dt><dd class="m-0 font-semibold">{$Languages.time|ldate:'long'}</dd></div>
                <div><dt class="font-mono text-xs text-slate-500">{literal}{$time|ldate:'short'}{/literal}</dt><dd class="m-0 font-semibold">{$Languages.time|ldate:'short'}</dd></div>
                <div><dt class="font-mono text-xs text-slate-500">{literal}{'/docs/'|lurl}{/literal}</dt><dd class="m-0 font-semibold">{'/docs/'|lurl}</dd></div>
            </dl>
        </div>
    </div>
</section>

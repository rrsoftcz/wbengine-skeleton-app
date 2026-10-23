{* Live demo: template syntax and its result, rendered by the template engine on this request. *}
<section class="mt-6 rounded-2xl border border-indigo-200 bg-indigo-50/60 p-6 lg:ml-[17rem]" aria-labelledby="demo-tpl">
    <p class="eyebrow py-0">{t 'demo.live'}</p>
    <h2 id="demo-tpl" class="mb-1 mt-1 text-xl">{t 'demo.tpl.title'}</h2>
    <p class="py-0 text-sm text-slate-600">{t 'demo.tpl.lead'}</p>
    <div class="mt-4 overflow-x-auto rounded-xl border border-slate-200 bg-white">
        <table class="w-full text-left text-sm">
            <thead class="bg-slate-100 text-slate-900"><tr><th class="px-4 py-2">{t 'demo.tpl.source'}</th><th class="px-4 py-2">{t 'demo.tpl.result'}</th></tr></thead>
            <tbody>
                <tr class="border-t border-slate-100"><td class="px-4 py-2 font-mono text-xs">{literal}{$hostile}{/literal}</td><td class="px-4 py-2">{$Templates.hostile}</td></tr>
                <tr class="border-t border-slate-100"><td class="px-4 py-2 font-mono text-xs">{literal}{$html}{/literal}</td><td class="px-4 py-2">{$Templates.html}</td></tr>
                <tr class="border-t border-slate-100"><td class="px-4 py-2 font-mono text-xs">{literal}{$html|raw}{/literal}</td><td class="px-4 py-2">{$Templates.html|raw}</td></tr>
                <tr class="border-t border-slate-100"><td class="px-4 py-2 font-mono text-xs">{literal}{$name|default:'anonymous'|upper}{/literal}</td><td class="px-4 py-2">{$Templates.name|default:'anonymous'|upper}</td></tr>
                <tr class="border-t border-slate-100"><td class="px-4 py-2 font-mono text-xs">{literal}{$text|truncate:24}{/literal}</td><td class="px-4 py-2">{$Templates.text|truncate:24}</td></tr>
                <tr class="border-t border-slate-100"><td class="px-4 py-2 font-mono text-xs">{literal}{$items|join:' / '}{/literal}</td><td class="px-4 py-2">{$Templates.items|join:' / '}</td></tr>
                <tr class="border-t border-slate-100"><td class="px-4 py-2 font-mono text-xs">{literal}{$price|number:2}{/literal}</td><td class="px-4 py-2">{$Templates.price|number:2}</td></tr>
                <tr class="border-t border-slate-100"><td class="px-4 py-2 font-mono text-xs">{literal}{$time|ldate:'long'}{/literal}</td><td class="px-4 py-2">{$Templates.time|ldate:'long'}</td></tr>
                <tr class="border-t border-slate-100"><td class="px-4 py-2 font-mono text-xs">{literal}{foreach $items as $i}{$i}{/foreach}{/literal}</td><td class="px-4 py-2">{foreach $Templates.items as $i}<span class="chip mr-1">{$i}</span>{/foreach}</td></tr>
                <tr class="border-t border-slate-100"><td class="px-4 py-2 font-mono text-xs">{literal}{if $price > 1000}...{/if}{/literal}</td><td class="px-4 py-2">{if $Templates.price > 1000}{t 'demo.tpl.expensive'}{else}{t 'demo.tpl.cheap'}{/if}</td></tr>
            </tbody>
        </table>
    </div>
</section>

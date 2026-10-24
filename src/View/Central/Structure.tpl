{* Live demo: the boxes that built this page. *}
<section class="mt-6 rounded-2xl border border-indigo-200 bg-indigo-50/60 p-6 lg:ml-[17rem]" aria-labelledby="demo-structure">
    <p class="eyebrow py-0">{t 'demo.live'}</p>
    <h2 id="demo-structure" class="mb-1 mt-1 text-xl">{t 'demo.structure.title'}</h2>
    <p class="py-0 text-sm text-slate-600">{t 'demo.structure.lead' url=$Structure.url id=$Structure.siteId}</p>
    <div class="mt-4 overflow-x-auto rounded-xl border border-slate-200 bg-white">
        <table class="w-full text-left text-sm">
            <thead class="bg-slate-100 text-slate-900">
                <tr><th class="px-4 py-2">{t 'demo.structure.section'}</th><th class="px-4 py-2">{t 'demo.structure.box'}</th><th class="px-4 py-2">{t 'demo.structure.class'}</th><th class="px-4 py-2">{t 'demo.structure.shared'}</th></tr>
            </thead>
            <tbody>
                {foreach $Structure.boxes as $b}
                <tr class="border-t border-slate-100">
                    <td class="px-4 py-2"><span class="chip">{$b.section}</span></td>
                    <td class="px-4 py-2">{$b.name}</td>
                    <td class="px-4 py-2 font-mono text-xs">{$b.module}::{$b.method}()</td>
                    <td class="px-4 py-2">{if $b.shared}{t 'demo.yes'}{else}{t 'demo.no'}{/if}</td>
                </tr>
                {/foreach}
            </tbody>
        </table>
    </div>
    <p class="py-0 pt-3 text-xs text-slate-600">{t 'demo.structure.note'}</p>
</section>

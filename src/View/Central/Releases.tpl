{* The changelog of the framework, newest release first. The entries are safe HTML from the Markdown of CHANGELOG.md. *}
<div class="mt-8">
    <section class="card sm:p-10">
        <p class="eyebrow py-0">{t 'changelog.eyebrow'}</p>
        <h1 class="mb-4 mt-2 text-3xl sm:text-4xl">{t 'changelog.title'}</h1>
        <p class="lead py-0">{t 'changelog.lead'}</p>
        <p class="pt-3 text-sm text-slate-600">{t 'changelog.running'} <strong>{if $wbengine_version == 'dev'}dev{else}v{$wbengine_version}{/if}</strong></p>
    </section>

    {if $Releases.available}
    {foreach $Releases.recent as $r}
    <section class="card mt-6 sm:p-8" id="v{$r.version}" aria-labelledby="h-{$r.version}">
        <h2 id="h-{$r.version}" class="mb-1 mt-0 text-2xl">v{$r.version} <span class="text-base font-medium text-slate-500">{$r.date}</span></h2>
        <p class="mb-4 mt-0 text-sm"><a href="https://github.com/rrsoftcz/wbengine/releases/tag/v{$r.version}">{t 'changelog.github'}</a></p>
        {foreach $r.groups as $g}
        <h3 class="mb-2 mt-5 text-lg">{$g.label}</h3>
        <ul class="m-0 list-disc space-y-2 pl-6">
            {foreach $g.entries as $e}<li>{$e|raw}</li>{/foreach}
        </ul>
        {/foreach}
    </section>
    {/foreach}

    {if $Releases.older}
    <details class="card mt-6 sm:p-8">
        <summary class="cursor-pointer text-lg font-semibold">{t 'changelog.older'}</summary>
        {foreach $Releases.older as $r}
        <section class="mt-6" id="v{$r.version}" aria-labelledby="h-{$r.version}">
            <h2 id="h-{$r.version}" class="mb-1 mt-0 text-xl">v{$r.version} <span class="text-base font-medium text-slate-500">{$r.date}</span></h2>
            {foreach $r.groups as $g}
            <h3 class="mb-2 mt-4 text-base">{$g.label}</h3>
            <ul class="m-0 list-disc space-y-2 pl-6">
                {foreach $g.entries as $e}<li>{$e|raw}</li>{/foreach}
            </ul>
            {/foreach}
        </section>
        {/foreach}
    </details>
    {/if}
    {else}
    <section class="card mt-6 sm:p-8"><p class="m-0">{t 'changelog.unavailable'}</p></section>
    {/if}
</div>

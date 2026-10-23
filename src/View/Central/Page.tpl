{* A documentation page: the sidebar, the article from the database (already in the visitor's language), previous and next. *}
<div class="mt-8 grid grid-cols-1 gap-8 lg:grid-cols-[15rem_minmax(0,1fr)]">
    <aside class="lg:sticky lg:top-24 lg:self-start" aria-label="{t 'doc.sidebar'}">
        <p class="eyebrow mb-2 py-0">{t 'doc.sidebar'}</p>
        <ol class="m-0 flex list-none gap-1 overflow-x-auto p-0 lg:flex-col lg:overflow-visible">
            {foreach $Page.nav as $n}
            <li class="shrink-0">
                <a class="flex items-center gap-3 rounded-lg px-3 py-2 text-sm font-medium no-underline transition {if $n.active}bg-indigo-600 text-white shadow-sm{else}text-slate-600 hover:bg-white hover:text-slate-900 hover:shadow-sm{/if}" href="{$n.link|lurl}"{if $n.active} aria-current="page"{/if}>
                    <span class="grid h-5 w-5 place-items-center rounded-md text-[11px] font-bold {if $n.active}bg-white/20 text-white{else}bg-slate-200 text-slate-600{/if}">{$n.number}</span>
                    <span class="whitespace-nowrap">{$n.key|t}</span>
                </a>
            </li>
            {/foreach}
        </ol>
    </aside>

    <article class="min-w-0 rounded-2xl border border-slate-200 bg-white p-6 shadow-sm sm:p-10">
        {if $Page.article}
        <h1 class="mb-4 mt-0 text-3xl sm:text-4xl">{$Page.article->title}</h1>
        {* The intro and the text are HTML written by administrators: trusted, printed as is. *}
        <div class="lead">{$Page.article->introtext|raw}</div>
        <div class="doc mt-8">
            {$Page.article->bodytext|raw}
        </div>
        {/if}

        <nav class="mt-12 grid grid-cols-1 gap-4 border-t border-slate-200 pt-6 sm:grid-cols-2" aria-label="{t 'doc.pager'}">
            {if $Page.prev}
            <a class="card no-underline hover:border-indigo-300" href="{$Page.prev.link|lurl}">
                <span class="text-xs font-semibold uppercase tracking-wider text-slate-500">&larr; {t 'doc.prev'}</span>
                <span class="mt-1 block font-semibold text-slate-900">{$Page.prev.key|t}</span>
            </a>
            {else}<span></span>{/if}
            {if $Page.next}
            <a class="card text-right no-underline hover:border-indigo-300" href="{$Page.next.link|lurl}">
                <span class="text-xs font-semibold uppercase tracking-wider text-slate-500">{t 'doc.next'} &rarr;</span>
                <span class="mt-1 block font-semibold text-slate-900">{$Page.next.key|t}</span>
            </a>
            {/if}
        </nav>
    </article>
</div>

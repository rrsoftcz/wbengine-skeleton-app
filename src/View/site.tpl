<!DOCTYPE html>
{set $loginUrl = '/login/'|lurl}
<html lang="{$lang|default:'en'}" class="scroll-smooth">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>{$meta.title|default:'WBengine'}{if $meta.title != 'WBengine'} | WBengine{/if}</title>
    <meta name="description" content="{$meta.description}">
    <meta name="keywords" content="{$meta.keywords}">
    <meta name="author" content="Radek Roža">
    <meta name="robots" content="index,follow">
    <meta name="theme-color" content="#4f46e5">
    <meta property="og:type" content="website">
    <meta property="og:title" content="{$meta.title}">
    <meta property="og:description" content="{$meta.description}">
    {foreach $alternates as $code => $url}
    <link rel="alternate" hreflang="{$code}" href="{$url}">
    {/foreach}
    <link rel="manifest" href="/manifest.json">
    <link rel="stylesheet" href="/Css/output.min.css">
    <link rel="icon" type="image/png" href="/Assets/favicon.ico">
</head>

<body class="flex min-h-screen flex-col">
    <a href="#main" class="sr-only focus:not-sr-only focus:absolute focus:left-4 focus:top-4 focus:z-50 focus:rounded focus:bg-white focus:px-3 focus:py-2">{t 'nav.skip'}</a>

    {* The navigation: its entries are the cms_menu rows of the site, translated per language. *}
    <header class="sticky top-0 z-30 border-b border-slate-200/80 bg-white/80 backdrop-blur">
        <div class="container-page flex items-center justify-between gap-4 py-3">
            <a href="{'/'|lurl}" class="flex items-center gap-2.5 no-underline">
                <span class="grid h-9 w-9 place-items-center rounded-xl bg-gradient-to-br from-indigo-600 via-violet-600 to-fuchsia-600 text-base font-extrabold text-white shadow-md">W</span>
                <span class="hidden text-lg font-bold tracking-tight text-slate-900 sm:inline">WBengine</span>
            </a>

            <nav class="hidden md:block" aria-label="{t 'nav.main'}">
                <ul class="m-0 flex list-none items-center gap-1 p-0">
                    {foreach $menu as $m}
                    <li><a class="block rounded-lg px-3 py-2 text-sm font-medium text-slate-600 no-underline transition hover:bg-slate-100 hover:text-slate-900 {$m->active()}" data-nav="{$m->link}" href="{$m->link|lurl}" title="{$m->description}">{$m->name}</a></li>
                    {/foreach}
                </ul>
            </nav>

            <div class="flex items-center gap-2">
                {* Language switcher: the same page in every language *}
                <ul class="m-0 flex list-none items-center rounded-lg bg-slate-100 p-0.5 text-xs font-semibold" aria-label="{t 'nav.language'}">
                    {foreach $alternates as $code => $url}
                    <li><a class="block rounded-md px-2.5 py-1 no-underline {if $code == $locale}bg-white text-indigo-700 shadow-sm{else}text-slate-500 hover:text-slate-900{/if}" href="{$url}" hreflang="{$code}" lang="{$code}">{$code|upper}</a></li>
                    {/foreach}
                </ul>
                {if $user && $user->isLogged() === true}
                <a class="btn-outline hidden sm:inline-flex" href="{'/profile/'|lurl}">{$user->getUserEmail()}</a>
                <a class="btn-primary px-3 sm:px-5" href="{$loginUrl}?a=logout" title="{t 'nav.logout_title'}">{t 'nav.logout'}</a>
                {else}
                <a class="btn-primary px-3 sm:px-5" href="{$loginUrl}" title="{t 'nav.signin_title'}">{t 'nav.signin'}</a>
                {/if}

                <button id="toggle-menu" type="button" class="grid h-10 w-10 place-items-center rounded-lg text-slate-600 hover:bg-slate-100 md:hidden" aria-controls="navbar" aria-expanded="false">
                    <span class="sr-only">{t 'nav.menu'}</span>
                    <svg class="h-5 w-5" aria-hidden="true" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 17 14">
                        <path stroke="currentColor" stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M1 1h15M1 7h15M1 13h15" />
                    </svg>
                </button>
            </div>
        </div>
        <div id="navbar" class="hidden border-t border-slate-200 bg-white md:hidden">
            <ul class="container-page m-0 flex list-none flex-col gap-1 py-3">
                {foreach $menu as $m}
                <li><a class="block rounded-lg px-3 py-2 font-medium text-slate-700 no-underline hover:bg-slate-100 {$m->active()}" data-nav="{$m->link}" href="{$m->link|lurl}">{$m->name}</a></li>
                {/foreach}
            </ul>
        </div>
    </header>

    <main id="main" class="flex-1">
        {* The sections are HTML built by the boxes: trusted, printed as is. *}
        {$header|raw}
        <div class="container-page pb-16">
            {$central|raw}
        </div>
    </main>

    <footer class="border-t border-slate-200 bg-white">
        <div class="container-page grid grid-cols-1 gap-8 py-12 md:grid-cols-4">
            <div class="md:col-span-2">
                <div class="flex items-center gap-2.5">
                    <span class="grid h-8 w-8 place-items-center rounded-lg bg-gradient-to-br from-indigo-600 via-violet-600 to-fuchsia-600 text-sm font-extrabold text-white">W</span>
                    <span class="font-bold text-slate-900">WBengine</span>
                </div>
                <p class="mt-3 max-w-md text-sm text-slate-500">{t 'footer.about'}</p>
            </div>
            <div>
                <h3 class="mb-3 mt-0 text-sm font-semibold uppercase tracking-wider text-slate-900">{t 'footer.docs'}</h3>
                <ul class="m-0 list-none space-y-2 p-0 text-sm">
                    <li><a class="no-underline hover:underline" href="{'/docs/'|lurl}">{t 'doc.getting_started'}</a></li>
                    <li><a class="no-underline hover:underline" href="{'/docs/architecture/'|lurl}">{t 'doc.architecture'}</a></li>
                    <li><a class="no-underline hover:underline" href="{'/docs/templates/'|lurl}">{t 'doc.templates'}</a></li>
                    <li><a class="no-underline hover:underline" href="{'/docs/rest-api/'|lurl}">{t 'doc.rest_api'}</a></li>
                </ul>
            </div>
            <div>
                <h3 class="mb-3 mt-0 text-sm font-semibold uppercase tracking-wider text-slate-900">{t 'footer.project'}</h3>
                <ul class="m-0 list-none space-y-2 p-0 text-sm">
                    <li><a class="no-underline hover:underline" href="https://github.com/rrsoftcz/wbengine">GitHub</a></li>
                    <li><a class="no-underline hover:underline" href="https://packagist.org/packages/wbengine/wbengine">Packagist</a></li>
                    <li><a class="no-underline hover:underline" href="https://www.rrsoft.cz">RRSOFT</a></li>
                </ul>
            </div>
        </div>
        <div class="border-t border-slate-100">
            <div class="container-page flex flex-col gap-2 py-4 text-xs text-slate-500 sm:flex-row sm:items-center sm:justify-between">
                <span>{t 'footer.rights'} &middot; &copy; 2008&ndash;2026 RRSOFT</span>
                <span>{$server} &middot; MySQL {$dbinfo} &middot; PHP {$phpversion}</span>
            </div>
        </div>
    </footer>

    {if ($debug)}
        {$debug->show()|raw}
    {/if}
    <script src="/menu.js" defer></script>
</body>
</html>

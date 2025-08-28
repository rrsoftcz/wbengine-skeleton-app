<!DOCTYPE html>
<html lang="cs">

<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
    <meta http-equiv="Content-language" content="cs">
    <meta http-equiv="Imagetoolbar" content="no">
    <meta name="description" content="Example of WBengine Skeleton Application">
    <meta name="resource-type" content="document">
    <meta name="rating" content="General">
    <meta name="author" content="Radek Roža - bajtlamer(at)gmail.com">
    <meta name="copyright" content="Copyright © 2024 RRsoft, All rigts reserverd. Email: bajtlamer(at)gmail.com">
    <meta name="robots" content="index,follow">
    <meta name="theme-color" content="#3F51B5">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <link rel="manifest" href="/manifest.json">
    <link rel="author" href="https://github.com/Bajtlamer">
    <link rel="StyleSheet" type="text/css" href="/Css/output.min.css">
    <title>{$meta.title}</title>
    <link rel="icon" type="image/png" href="/Assets/favicon.ico">
</head>

<body class="bg-slate-200">
    <div class="">
        <nav
            class="bg-blue-700 text-slate-100 fixed w-full z-20 top-0 start-0 border-b border-gray-800 shadow-md">
            <div class="max-w-screen-lg flex flex-wrap items-center justify-between mx-auto p-4">
                <a href="/" class="flex items-center text-slate-200 space-x-3 rtl:space-x-reverse no-underline">
                    <img src="/Assets/logo.svg" class="h-10" alt="WBengine Logo">
                    <span class="self-center text-2xl font-semibold whitespace-nowrap">WBengine</span>
                </a>
                <div class="flex md:order-2 space-x-3 md:space-x-0 rtl:space-x-reverse">
                {if $user && $user->isLogged() === true}
                    <a class="nav-link a-login" href="/login/?a=logout" title="Přihlásit se do systému">
                        <button type="button" class="btn-white">Logout</button>
                    </a>
                {else}
                    <a class="nav-link a-login" href="/login/" title="Přihlásit se do systému">
                        <button type="button" class="btn-white">Sign In</button>
                    </a>
                {/if}

                    <button id="toggle-menu" data-collapse-toggle="navbar-sticky" type="button"
                        class="bg-gray-200 inline-flex items-center p-2 w-10 h-10 justify-center text-sm text-gray-500 rounded-lg md:hidden hover:bg-gray-100 focus:outline-none focus:ring-2 focus:ring-gray-100"
                        aria-controls="navbar-sticky" aria-expanded="false">
                        <span class="sr-only">Open main menu</span>
                        <svg class="w-5 h-5" aria-hidden="true" xmlns="http://www.w3.org/2000/svg" fill="none"
                            viewBox="0 0 17 14">
                            <path stroke="currentColor" stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                                d="M1 1h15M1 7h15M1 13h15" />
                        </svg>
                    </button>
                </div>
                <div class="items-center justify-between hidden w-full md:flex md:w-auto md:order-1" id="navbar-sticky">
                    <ul
                        class="flex flex-col p-3 md:p-0 mt-4 font-medium md:space-x-8 rtl:space-x-reverse md:flex-row md:mt-0 md:border-0">
                        {foreach $menu as $m}
                            <li>
                                <a class="p-2 no-underline border-b-2 text-gray-100 border-blue-700 hover:border-blue-400 {$m->active()}" href="{$m->link}" title="{$m->description}">{$m->name}</a>
                            </li>
                        {/foreach}
                    </ul>
                </div>
                <div class="mt-4 border-t-1 border-gray-100 items-center justify-between hidden w-full md:hidden" id="navbar">
                    <ul class="flex flex-row mt-2 font-medium md:space-x-8 rtl:space-x-reverse md:flex-row md:mt-0 md:border-0">
                        {foreach $menu as $m}
                            <li>
                                <a class="p-2 no-underline border-b-2 text-gray-100 border-blue-700 hover:border-blue-400 {$m->active()}" href="{$m->link}" title="{$m->description}">{$m->name}</a>
                            </li>
                        {/foreach}
                    </ul>
                </div>
            </div>
        </nav>
    </div>
    <div class="m-auto max-w-screen-lg">
        {$header}
        {$central}
    </div>

    <div class="m-auto max-w-screen-lg">
        <div class="text-center">
            <p>Powered by <a href="https://packagist.org/packages/wbengine/wbengine">WBengine</a>, {$server}, MySQL
                {$dbinfo}
                and PHP {$phpversion}, Hosted By <a href="https://www.rrsoft.cz">RRsoft</a> &copy; 2008 - 2024 All
                Rights
                Reserved</p>
        </div>
    </div>
    {if ($debug)}
        {$debug->show()}
    {/if}
</body>
<script src="./menu.js"></script>
</html>
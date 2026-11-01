{* The overview of the blog: the newest posts with an excerpt, the most read ones and the list of all posts. *}
<div class="mt-8">
    <section class="card sm:p-10">
        <p class="eyebrow py-0">{t 'blog.eyebrow'}</p>
        <h1 class="mb-4 mt-2 text-3xl sm:text-4xl">{t 'blog.title'}</h1>
        <p class="lead py-0">{t 'blog.lead'}</p>
    </section>

    {if $Overview.count}
    <section class="mt-6" aria-labelledby="blog-newest">
        <h2 id="blog-newest" class="mb-4 mt-0 text-2xl">{t 'blog.newest'}</h2>
        <div class="grid grid-cols-1 gap-6 md:grid-cols-2">
            {foreach $Overview.newest as $p}
            <article class="card flex flex-col sm:p-8">
                <p class="m-0 text-xs font-semibold uppercase tracking-wider text-slate-500">{$p.date}{if $p.author} &middot; {$p.author}{/if}</p>
                <h3 class="mb-2 mt-2 text-xl"><a class="no-underline" href="{$p.link|lurl}">{$p.title}</a></h3>
                <p class="m-0 text-slate-700">{$p.excerpt}</p>
                <p class="mb-0 mt-4 text-sm"><a href="{$p.link|lurl}">{t 'blog.read'}</a></p>
            </article>
            {/foreach}
        </div>
    </section>

    {if $Overview.popular}
    <section class="card mt-6 sm:p-8" aria-labelledby="blog-popular">
        <h2 id="blog-popular" class="mb-3 mt-0 text-2xl">{t 'blog.popular'}</h2>
        <ol class="m-0 list-decimal space-y-2 pl-6">
            {foreach $Overview.popular as $p}
            <li><a href="{$p.link|lurl}">{$p.title}</a> <span class="text-sm text-slate-500">{t 'blog.views' count=$p.views}</span></li>
            {/foreach}
        </ol>
    </section>
    {/if}

    <section class="card mt-6 sm:p-8" aria-labelledby="blog-all">
        <h2 id="blog-all" class="mb-3 mt-0 text-2xl">{t 'blog.all'}</h2>
        <ul class="m-0 list-none space-y-2 p-0">
            {foreach $Overview.all as $p}
            <li><span class="text-sm text-slate-500">{$p.date}</span> <a href="{$p.link|lurl}">{$p.title}</a></li>
            {/foreach}
        </ul>
    </section>
    {else}
    <section class="card mt-6 sm:p-8"><p class="m-0">{t 'blog.empty'}</p></section>
    {/if}
</div>

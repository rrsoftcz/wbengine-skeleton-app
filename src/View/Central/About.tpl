{* A static box: a template and no data. This one is shown on the site "/about/". *}
<div class="mt-8 grid grid-cols-1 gap-6 lg:grid-cols-3">
    <section class="card lg:col-span-2 sm:p-10">
        <p class="eyebrow py-0">{t 'about.eyebrow'}</p>
        <h1 class="mb-4 mt-2 text-3xl sm:text-4xl">{t 'about.title'}</h1>
        <p class="lead py-0">{t 'about.lead'}</p>
        <p class="pt-4">{t 'about.static'}</p>
        <p class="pt-3">{t 'about.template' path='src/View/Central/About.tpl'}</p>
        <div class="mt-6 flex flex-wrap gap-3">
            <a class="btn-primary" href="{'/docs/boxes/'|lurl}">{t 'about.cta_boxes'}</a>
            <a class="btn-outline" href="https://github.com/rrsoftcz/wbengine">{t 'about.cta_source'}</a>
        </div>
    </section>
    <aside class="card self-start">
        <h2 class="mb-3 mt-0 text-lg">{t 'about.facts'}</h2>
        <ul class="m-0 list-none space-y-3 p-0 text-sm">
            <li><span class="chip">PHP</span> <span class="ml-2">{t 'about.fact_php'}</span></li>
            <li><span class="chip">DB</span> <span class="ml-2">{t 'about.fact_db'}</span></li>
            <li><span class="chip">MIT</span> <span class="ml-2">{t 'about.fact_license'}</span></li>
            <li><span class="chip">CI</span> <span class="ml-2">{t 'about.fact_ci'}</span></li>
        </ul>
    </aside>
</div>

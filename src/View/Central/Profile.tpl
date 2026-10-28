<div class="mx-auto mt-10 max-w-xl">
    <div class="card p-8">
        <p class="eyebrow py-0">{t 'profile.eyebrow'}</p>
        <h1 class="mb-4 mt-2 text-3xl">{t 'profile.title'}</h1>
        {if $Profile.logged}
            <p class="py-0">{t 'profile.signed_in' email=$Profile.email raw}</p>
            <p class="py-0 pt-3 text-sm text-slate-600">{t 'profile.note'}</p>
            {if $Profile.admin}
                <h2 class="mb-2 mt-6 text-xl">{t 'profile.admin_title'}</h2>
                <p class="py-0 text-sm text-slate-600">{t 'profile.admin_text'}</p>
                <p class="py-0 pt-3"><a class="btn-outline" href="{'/integrations/'|lurl}">{t 'profile.admin_link'}</a></p>
            {/if}
        {else}
            <p class="py-0">{t 'profile.anonymous'}</p>
        {/if}
    </div>
</div>

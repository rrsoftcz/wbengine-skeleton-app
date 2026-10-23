<div class="story">
    <h1 class="hero-header">{t 'profile.title'}</h1>
    {if $Profile.logged}
        <p>{t 'profile.signed_in' email=$Profile.email raw}</p>
    {else}
        <p>{t 'profile.anonymous'}</p>
    {/if}
</div>

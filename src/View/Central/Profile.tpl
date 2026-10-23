<div class="story">
    <h1 class="hero-header">Profile</h1>
    {if $Profile.logged}
        <p>You are signed in as <b>{$Profile.email|escape}</b>.</p>
    {else}
        <p>You are not signed in.</p>
    {/if}
</div>

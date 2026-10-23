{* A dynamic box of the application itself: data from a model, then a template. *}
<article class="story">
    {if $LocalStoryBox->title}
        <h1>{$LocalStoryBox->title}</h1>
    {/if}
    {* Article text is HTML written by administrators: trusted, printed as is. *}
    <div class="lead">{$LocalStoryBox->introtext|raw}</div>
    <div class="doc mt-6">{$LocalStoryBox->bodytext|raw}</div>
</article>

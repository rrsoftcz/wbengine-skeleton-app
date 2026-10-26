{* A dynamic box of the application itself: data from a model, then a template. *}
<article class="story">
    {if $LocalStoryBox->title}
        <h1>{$LocalStoryBox->title}</h1>
    {/if}
    {* Legacy HTML stays trusted; Markdown is safely rendered by the box first. *}
    <div class="lead">{$LocalStoryBox->introtext|raw}</div>
    <div class="doc mt-6">{$LocalStoryBox->bodytext|raw}</div>
</article>

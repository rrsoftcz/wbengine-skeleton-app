<!-- START STORY BOX -->
<div class="story">
    {if $LocalStoryBox->title}
        <h1>{$LocalStoryBox->title}</h1>
    {/if}
    {if $LocalStoryBox->author}
        <p><i>Author:</i> <b><a href="#">{$LocalStoryBox->author}</a></b>, <i>Source:</i> <a href="{$LocalStoryBox->source}"> {$LocalStoryBox->source}</a></p>
    {/if}
    <!-- story box content start -->
    {* Article text is HTML written by administrators: trusted, printed as is. *}
    {$LocalStoryBox->introtext|raw}
    {$LocalStoryBox->bodytext|raw}
    <!-- story box content end -->
    <p>&nbsp;</p>
</div>
<!-- END STORY BOX -->
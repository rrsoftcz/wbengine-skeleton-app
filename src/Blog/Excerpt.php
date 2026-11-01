<?php

namespace App\Blog;

/** A short plain-text excerpt of an introduction: the markup removed, cut at a whole word. */
final class Excerpt
{
    public const LENGTH = 200;

    /** @param string $html the rendered introduction (Markdown already turned into HTML) */
    public static function plain(string $html, int $max = self::LENGTH): string
    {
        $text = html_entity_decode(strip_tags(preg_replace('~</(p|li|h[1-6]|div|br)>|<br\s*/?>~i', ' ', $html) ?? $html), ENT_QUOTES | ENT_HTML5, 'UTF-8');
        $text = trim((string) preg_replace('/\s+/u', ' ', $text));
        if (mb_strlen($text) <= $max) { return $text; }
        $cut = mb_substr($text, 0, $max);
        $space = mb_strrpos($cut, ' ');
        // A single very long word has no space to cut at: cut it.
        $cut = false === $space || $space < (int) ($max / 2) ? $cut : mb_substr($cut, 0, $space);
        return rtrim($cut, " \t.,;:!?-") . '...';
    }
}

<?php

declare(strict_types=1);

// The excerpt of a blog post on /blog/: plain text from the rendered introduction, cut at a whole word.
require dirname(__DIR__) . '/vendor/autoload.php';

use App\Blog\Excerpt;

$expect = static function (bool $ok, string $message): void { if (!$ok) { throw new RuntimeException($message); } };

$expect(Excerpt::plain('<p>Short text.</p>') === 'Short text.', 'a short text is kept');
$expect(Excerpt::plain("<p>One</p>\n<p>Two <strong>bold</strong> &amp; <em>more</em></p>") === 'One Two bold & more', 'markup is removed, entities decoded, paragraphs separated by a space');
$expect(Excerpt::plain('<script>alert(1)</script><p>Text</p>') === 'alert(1)Text', 'tags are removed (the page escapes the result on output)');
$long = '<p>' . str_repeat('word ', 80) . '</p>';
$cut = Excerpt::plain($long, 50);
$expect(mb_strlen($cut) <= 53 && str_ends_with($cut, '...') && !str_contains($cut, 'wor...'), 'a long text is cut at a whole word and marked: ' . $cut);
$expect(preg_match('/ \.\.\.$/', $cut) === 0, 'no space before the dots');
$czech = Excerpt::plain('<p>' . str_repeat('Příliš žluťoučký kůň ', 20) . '</p>', 60);
$expect(str_ends_with($czech, '...') && mb_check_encoding($czech, 'UTF-8') && !str_contains($czech, "\xEF\xBF\xBD"), 'multibyte text is cut on a character boundary: ' . $czech);
$one = Excerpt::plain('<p>' . str_repeat('x', 300) . '</p>', 40);
$expect($one === str_repeat('x', 40) . '...', 'one very long word is cut');
$expect(Excerpt::plain('') === '' && Excerpt::plain('<p></p>') === '', 'nothing gives nothing');
echo "blog excerpt: ok\n";

<?php
namespace App\Box\Central\Article;
use App\Box\Central\Blog;
use Wbengine\Box\BoxTemplate;
use Wbengine\Db;
use Wbengine\I18n\ContentTranslations;
use Wbengine\Model\ModelAbstract;
use Wbengine\Site;

class Model extends ModelAbstract
{
    /**
     * Parent site object
     * @var Site
     */
    private $site = NULL;
    /**
     * @var
     */
    private $boxStory;
    /**
     * We do nothink in constructor.
     * @param Story $boxStory
     */
    public function __construct($boxStory)
    {
        $this->site = $boxStory->getSite();
        $this->boxStory = $boxStory;
    }
    /**
     * Return story data from db
     * @return \stdClass
     */
    public function getArticleRow()
    {
        $sql = sprintf("SELECT 
                          a.introtext, 
                          a.bodytext, 
                          a.content_format,
                          a.id, 
                          a.title, 
                          a.published, 
                          a.author, 
                          a.views, 
                          a.source  
                        FROM %s a
                        WHERE  site_id = ? LIMIT 1;"
            ,S_TABLE_ARTICLES
        );
        // Title, intro and body in the visitor's language, field by field, default when untranslated.
        return ContentTranslations::overlayRow('article', Db::fetchObject($sql, array((int)$this->site->getSiteId())));
    }

    /**
     * Update blog view in article table...
     * @param BoxTemplate $box
     * @return \mysqli_result
     * @throws Db\Exception\DbException
     */
    Public function updateViews($box)
    {
        $sql = sprintf("UPDATE %s SET views = views + 1 WHERE site_id = ?;", S_TABLE_ARTICLES);
        return Db::query($sql, array((int)$box->getSite()->getSiteId()));
    }
}

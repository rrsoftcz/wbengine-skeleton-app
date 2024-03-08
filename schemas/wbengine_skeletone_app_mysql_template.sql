-- MySQL dump 10.13  Distrib 5.7.21, for osx10.13 (x86_64)
--
-- Host: localhost    Database: wb_skeleton_app
-- ------------------------------------------------------
-- Server version	5.7.21

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `cms_articles`
--

DROP TABLE IF EXISTS `cms_articles`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `cms_articles` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `site_id` int(10) NOT NULL DEFAULT '0',
  `grouped` tinyint(1) NOT NULL DEFAULT '0',
  `futured` tinyint(3) NOT NULL DEFAULT '0',
  `c_enabled` tinyint(3) NOT NULL DEFAULT '0',
  `views` int(10) DEFAULT '0',
  `title` varchar(255) COLLATE utf8_czech_ci DEFAULT NULL,
  `introtext` text COLLATE utf8_czech_ci,
  `bodytext` text COLLATE utf8_czech_ci,
  `published` int(11) NOT NULL DEFAULT '0',
  `author` varchar(255) COLLATE utf8_czech_ci DEFAULT NULL,
  `source` varchar(255) COLLATE utf8_czech_ci DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `site_id` (`site_id`),
  KEY `grouped` (`grouped`),
  KEY `future` (`futured`),
  KEY `c_enabled` (`c_enabled`),
  KEY `views` (`views`),
  KEY `title` (`title`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8 COLLATE=utf8_czech_ci ROW_FORMAT=DYNAMIC;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `cms_articles`
--

LOCK TABLES `cms_articles` WRITE;
/*!40000 ALTER TABLE `cms_articles` DISABLE KEYS */;
INSERT INTO `cms_articles` VALUES (1,2,0,0,0,83,'Blog Example','<p>Lorem ipsum dolor sit amet, consectetur adipiscing elit. Integer nec odio. Praesent libero. Sed cursus ante dapibus diam. Sed nisi. Nulla quis sem at nibh elementum imperdiet. Duis sagittis ipsum. Praesent mauris. Fusce nec tellus sed augue semper porta. Mauris massa. Vestibulum lacinia arcu eget nulla. </p>','<h2>Website Blog example</h2>\n\n<p><strong>Pellentesque habitant morbi tristique</strong> senectus et netus et malesuada fames ac turpis egestas. Vestibulum tortor quam, feugiat vitae, ultricies eget, tempor sit amet, ante. Donec eu libero sit amet quam egestas semper. <em>Aenean ultricies mi vitae est.</em> Mauris placerat eleifend leo. Quisque sit amet est et sapien ullamcorper pharetra. Vestibulum erat wisi, condimentum sed, <code>commodo vitae</code>, ornare sit amet, wisi. Aenean fermentum, elit eget tincidunt condimentum, eros ipsum rutrum orci, sagittis tempus lacus enim ac dui. <a href=\"#\">Donec non enim</a> in turpis pulvinar facilisis. Ut felis.</p>\n<p>Pellentesque habitant morbi tristique senectus et netus et malesuada fames ac turpis egestas. Vestibulum tortor quam, feugiat vitae, ultricies eget, tempor sit amet, ante. Donec eu libero sit amet quam egestas semper. Aenean ultricies mi vitae est. Mauris placerat eleifend leo.</p>\n<ul class=\"list-group\">\n   <li>Lorem ipsum dolor sit amet, consectetuer adipiscing elit.</li>\n   <li>Aliquam tincidunt mauris eu risus.</li>\n   <li>Vestibulum auctor dapibus neque.</li>\n</ul>\n<p>Pellentesque habitant morbi tristique senectus et netus et malesuada fames ac turpis egestas. Vestibulum tortor quam, feugiat vitae, ultricies eget, tempor sit amet, ante. Donec eu libero sit amet quam egestas semper. Aenean ultricies mi vitae est. Mauris placerat eleifend leo.</p>',1491903057,'Blogger name','https://www.rrsoft.cz');
/*!40000 ALTER TABLE `cms_articles` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `cms_boxes`
--

DROP TABLE IF EXISTS `cms_boxes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `cms_boxes` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(150) CHARACTER SET utf8 NOT NULL,
  `module` varchar(45) CHARACTER SET utf8 NOT NULL,
  `method` varchar(45) CHARACTER SET utf8 NOT NULL,
  `section_id` int(10) unsigned NOT NULL DEFAULT '0',
  `static` tinyint(1) unsigned NOT NULL DEFAULT '0',
  `shared` tinyint(1) unsigned NOT NULL DEFAULT '0',
  `device_min` tinyint(1) DEFAULT '1' COMMENT '1=mobile,2=tablets,3=desctop',
  `device_strict` tinyint(1) DEFAULT '0' COMMENT 'strict to device type',
  `acl` int(1) DEFAULT '0',
  `order` int(3) DEFAULT '0',
  `sites` json DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `section_id` (`section_id`),
  KEY `static` (`static`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8 COLLATE=utf8_czech_ci ROW_FORMAT=DYNAMIC COMMENT='Boxes list';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `cms_boxes`
--

LOCK TABLES `cms_boxes` WRITE;
/*!40000 ALTER TABLE `cms_boxes` DISABLE KEYS */;
INSERT INTO `cms_boxes` VALUES (1,'Jumbotron','Jumbotron','jumbotron',4,1,0,1,0,0,1,'[\"1\"]'),(2,'Login box','login','login',1,1,0,1,0,0,2,'[\"7\"]'),(3,'API','restapi','restapi',5,1,0,1,0,1,0,'[\"8\"]'),(4,'User\'s Profile','profile','profile',1,1,0,1,0,1,1,'[\"9\"]'),(5,'About box','staticBoxes','about',1,1,0,1,0,0,0,'[\"3\"]'),(6,'Article blog box','blog','story',1,1,0,1,0,0,0,'[\"2\"]');
/*!40000 ALTER TABLE `cms_boxes` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `cms_landcodes`
--

DROP TABLE IF EXISTS `cms_landcodes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `cms_landcodes` (
  `landcode_id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `landid` int(11) unsigned DEFAULT '0',
  `landcode` char(3) CHARACTER SET cp1250 COLLATE cp1250_czech_cs DEFAULT '0',
  `landname_cz` varchar(200) CHARACTER SET cp1250 COLLATE cp1250_czech_cs DEFAULT '0',
  `landname_en` varchar(200) CHARACTER SET cp1250 COLLATE cp1250_czech_cs DEFAULT '0',
  PRIMARY KEY (`landcode_id`)
) ENGINE=InnoDB AUTO_INCREMENT=2048 DEFAULT CHARSET=utf8 COLLATE=utf8_czech_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `cms_landcodes`
--

LOCK TABLES `cms_landcodes` WRITE;
/*!40000 ALTER TABLE `cms_landcodes` DISABLE KEYS */;
INSERT INTO `cms_landcodes` VALUES (1818,660,'AF','Afghánistán','Afghanistan'),(1819,70,'AL','Albánie','Albania'),(1820,208,'DZ','Alžírsko','Algeria'),(1821,830,'AS','Americká Samoa','American Samoa'),(1822,457,'VI','Americké Panenské ostrovy','Virgin Islands (U.S.)'),(1823,43,'AD','Andorra','Andorra'),(1824,330,'AO','Angola','Angola'),(1825,446,'AI','Anguilla','Anguilla'),(1826,891,'AQ','Antarktida','Antarctica'),(1827,459,'AG','Antigua a Barbuda','Antigua and Barbuda'),(1828,528,'AR','Argentina','Argentina'),(1829,77,'AM','Arménie','Armenia'),(1830,474,'AW','Aruba','Aruba'),(1831,800,'AU','Austrálie','Australia'),(1832,78,'AZ','Ázerbájdžán','Azerbaijan'),(1833,453,'BS','Bahamy','Bahamas'),(1834,640,'BH','Bahrajn','Bahrain'),(1835,666,'BD','Bangladéš','Bangladesh'),(1836,469,'BB','Barbados','Barbados'),(1837,17,'BE','Belgie','Belgium'),(1838,421,'BZ','Belize','Belize'),(1839,73,'BY','Bělorusko','Belarus (též Belorussia)'),(1840,284,'BJ','Benin','Benin'),(1841,413,'BM','Bermudy','Bermuda'),(1842,675,'BT','Bhútán','Bhutan'),(1843,516,'BO','Bolívie','Bolivia'),(1844,93,'BA','Bosna a Hercegovina','Bosnia and Herzegovina'),(1845,391,'BW','Botswana','Botswana'),(1846,892,'BV','Bouvetův ostrov','Bouvet Island'),(1847,508,'BR','Brazílie','Brazil'),(1848,357,'IO','Britské indickooceánské území','British Indian Ocean Territory'),(1849,468,'VG','Britské Panenské ostrovy','Virgin Islands (British)'),(1850,703,'BN','Brunej Darussalam','Brunei Darussalam (též Brunei)'),(1851,68,'BG','Bulharsko','Bulgaria'),(1852,236,'BF','Burkina Faso','Burkina Faso'),(1853,328,'BI','Burundi','Burundi'),(1854,21,'XC','Ceuta','Ceuta'),(1855,837,'CK','Cookovy ostrovy','Cook Islands'),(1856,244,'TD','Čad','Chad'),(1857,61,'CZ','Česká republika','Czech Republic'),(1858,720,'CN','Čína','China'),(1859,8,'DK','Dánsko','Denmark'),(1860,460,'DM','Dominika','Dominica'),(1861,456,'DO','Dominikánská republika','Dominican Republic'),(1862,338,'DJ','Džibutsko','Djibouti'),(1863,220,'EG','Egypt','Egypt'),(1864,500,'EC','Ekvádor','Ecuador'),(1865,336,'ER','Eritrea','Eritrea'),(1866,53,'EE','Estonsko','Estonia'),(1867,334,'ET','Etiopie','Ethiopia'),(1868,41,'FO','Faerské ostrovy','Faeroe Islands'),(1869,529,'FK','Falklandy','Falkland Islands'),(1870,815,'FJ','Fidži','Fiji'),(1871,708,'PH','Filipíny','Philippines'),(1872,32,'FI','Finsko','Finland'),(1873,1,'FR','Francie','France'),(1874,894,'TF','Francouzská jižní území','French Southern Territories'),(1875,822,'PF','Francouzská Polynésie','French Polynesia'),(1876,314,'GA','Gabon','Gabon'),(1877,252,'GM','Gambie','Gambia'),(1878,276,'GH','Ghana','Ghana'),(1879,44,'GI','Gibraltar','Gibraltar'),(1880,473,'GD','Grenada','Grenada'),(1881,406,'GL','Grónsko','Greenland'),(1882,76,'GE','Gruzie','Georgia'),(1883,831,'GU','Guam','Guam'),(1884,416,'GT','Guatemala','Guatemala'),(1885,260,'GN','Guinea','Guinea'),(1886,257,'GW','Guinea-Bissau','Guinea-Bissau'),(1887,488,'GY','Guyana','Guyana'),(1888,452,'HT','Haiti','Haiti'),(1889,835,'HM','Heardův ostrov a McDonaldovy ostrovy','Heard Island and McDonald Islands'),(1890,424,'HN','Honduras','Honduras'),(1891,740,'HK','Hongkong','Hong Kong'),(1892,512,'CL','Chile','Chile'),(1893,92,'HR','Chorvatsko','Croatia'),(1894,664,'IN','Indie','India'),(1895,700,'ID','Indonésie','Indonesia'),(1896,612,'IQ','Irák','Iraq'),(1897,616,'IR','Írán','Iran (Islamic Republic of) (též Iran)'),(1898,7,'IE','Irsko','Ireland'),(1899,24,'IS','Island','Iceland'),(1900,5,'IT','Itálie','Italy'),(1901,624,'IL','Izrael','Israel'),(1902,464,'JM','Jamajka','Jamaica'),(1903,732,'JP','Japonsko','Japan'),(1904,653,'YE','Jemen','Yemen'),(1905,388,'ZA','Jihoafrická republika','South Africa'),(1906,893,'GS','Jižní Georgie a Jižní Sandwichovy ostrovy','South Georgia and South Sandwich Islands'),(1907,628,'JO','Jordánsko','Jordan'),(1908,94,'YU','Jugoslávie','Yugoslavia'),(1909,463,'KY','Kajmanské ostrovy','Cayman Islands'),(1910,696,'KH','Kambodža','Cambodia'),(1911,302,'CM','Kamerun','Cameroon'),(1912,404,'CA','Kanada','Canada'),(1913,247,'CV','Kapverdy','Cape Verde'),(1914,644,'QA','Katar','Qatar'),(1915,79,'KZ','Kazachstán','Kazakhstan'),(1916,346,'KE','Keňa','Kenya'),(1917,812,'KI','Kiribati','Kiribati'),(1918,833,'CC','Kokosové ostrovy','Cocos Islands'),(1919,480,'CO','Kolumbie','Colombia'),(1920,375,'KM','Komory','Comoros'),(1921,318,'CG','Kongo','Congo'),(1922,322,'CD','Kongo, demokratická republika','Congo (Democratic Republic of)'),(1923,728,'KR','Korea','Korea (Republic of), South Korea)'),(1924,724,'KP','Korea, lidově demokratická republika','Korea (Democratic People\'s Republic of) (též North Korea)'),(1925,436,'CR','Kostarika','Costa Rica'),(1926,448,'CU','Kuba','Cuba'),(1927,636,'KW','Kuvajt','Kuwait'),(1928,600,'CY','Kypr','Cyprus'),(1929,83,'KG','Kyrgyzstán','Kyrgyzstan'),(1930,684,'LA','Laos','Lao (People\'s Democratic Republic of) (též Laos)'),(1931,395,'LS','Lesotho','Lesotho'),(1932,604,'LB','Libanon','Lebanon'),(1933,268,'LR','Libérie','Liberia'),(1934,216,'LY','Libye','Libyan Arab Jamahiriya (též Libya)'),(1935,37,'LI','Lichtenštejnsko','Liechtenstein'),(1936,55,'LT','Litva','Lithuania'),(1937,54,'LV','Lotyšsko','Latvia'),(1938,18,'LU','Lucembursko','Luxembourg'),(1939,743,'MO','Macao','Macao'),(1940,370,'MG','Madagaskar','Madagascar'),(1941,64,'HU','Maďarsko','Hungary'),(1942,96,'MK','Makedonie','Former Yugoslav Republic of Macedonia'),(1943,701,'MY','Malajsie','Malaysia'),(1944,386,'MW','Malawi','Malawi'),(1945,667,'MV','Maledivy','Maldives'),(1946,232,'ML','Mali','Mali'),(1947,46,'MT','Malta','Malta'),(1948,204,'MA','Maroko','Morocco'),(1949,824,'MH','Marshallovy ostrovy','Marshall Islands'),(1950,373,'MU','Mauricius','Mauritius'),(1951,228,'MR','Mauritánie','Mauritania'),(1952,377,'YT','Mayotte','Mayotte'),(1953,23,'XL','Melilla','Melilla'),(1954,832,'UM','Menší odlehlé ostrovy USA','United States Minor Outlying Islands'),(1955,412,'MX','Mexiko','Mexico'),(1956,823,'FM','Mikronésie','Micronesia (Federated States of)'),(1957,74,'MD','Moldavsko','Moldova (Republic of)'),(1958,716,'MN','Mongolsko','Mongolia'),(1959,470,'MS','Montserrat','Montserrat'),(1960,366,'MZ','Mosambik','Mozambique'),(1961,676,'MM','Myanmar','Myanmar (též Burma)'),(1962,389,'NA','Namibie','Namibia'),(1963,803,'NR','Nauru','Nauru'),(1964,4,'DE','Německo','Germany'),(1965,672,'NP','Nepál','Nepal'),(1966,240,'NE','Niger','Niger'),(1967,288,'NG','Nigérie','Nigeria'),(1968,432,'NI','Nikaragua','Nicaragua'),(1969,838,'NU','Niue','Niue Island'),(1970,478,'AN','Nizozemské Antily','Netherlands Antilles'),(1971,3,'NL','Nizozemsko','Netherlands'),(1972,836,'NF','Norfolk','Norfolk Island'),(1973,28,'NO','Norsko','Norway'),(1974,809,'NC','Nová Kaledonie','New Caledonia'),(1975,804,'NZ','Nový Zéland','New Zealand'),(1976,625,'PS','Okupované palestinské území','Occupied Palestinian Territory'),(1977,649,'OM','Omán','Oman'),(1978,662,'PK','Pákistán','Pakistan'),(1979,825,'PW','Palau','Palau'),(1980,442,'PA','Panama','Panama'),(1981,801,'PG','Papua Nová Guinea','Papua New Guinea'),(1982,520,'PY','Paraguay','Paraguay'),(1983,504,'PE','Peru','Peru'),(1984,813,'PN','Pitcairn','Pitcairn'),(1985,272,'CI','Pobřeží slonoviny','Côte ď Ivoire (též Ivory Coast)'),(1986,60,'PL','Polsko','Poland'),(1987,10,'PT','Portugalsko','Portugal'),(1988,38,'AT','Rakousko','Austria'),(1989,310,'GQ','Rovníková Guinea','Equatorial Guinea'),(1990,66,'RO','Rumunsko','Romania'),(1991,75,'RU','Rusko','Russian Federation'),(1992,324,'RW','Rwanda','Rwanda'),(1993,9,'GR','Řecko','Greece'),(1994,408,'PM','Saint Pierre a Miquelon','St Pierre and Miquelon'),(1995,428,'SV','Salvador','El Salvador'),(1996,819,'WS','Samoa','Samoa'),(1997,47,'SM','San Marino','San Marino'),(1998,632,'SA','Saúdská Arábie','Saudi Arabia'),(1999,248,'SN','Senegal','Senegal'),(2000,820,'MP','Severní Mariany','Northern Mariana Islands'),(2001,355,'SC','Seychely','Seychelles'),(2002,264,'SL','Sierra Leone','Sierra Leone'),(2003,706,'SG','Singapur','Singapore'),(2004,63,'SK','Slovensko','Slovakia'),(2005,91,'SI','Slovinsko','Slovenia'),(2006,342,'SO','Somálsko','Somalia'),(2007,647,'AE','Spojené arabské emiráty','United Arab Emirates'),(2008,6,'GB','Spojené království','United Kingdom'),(2009,400,'US','Spojené státy','United States'),(2010,669,'LK','Srí Lanka','Sri Lanka'),(2011,306,'CF','Středoafrická republika','Central African Republic'),(2012,224,'SD','Súdán','Sudan'),(2013,492,'SR','Surinam','Surinam'),(2014,329,'SH','Svatá Helena','St Helena'),(2015,465,'LC','Svatá Lucie','St Lucia'),(2016,449,'KN','Svatý Kryštof a Nevis','St Kitts and Nevis'),(2017,45,'VA','Svatý stolec','Holy See (též Vatican City)'),(2018,311,'ST','Svatý Tomáš','Sao Tomé and Principe'),(2019,467,'VC','Svatý Vincenc a Grenadiny','St Vincent and the Grenadines'),(2020,393,'SZ','Svazijsko','Swaziland'),(2021,608,'SY','Sýrie','Syrian Arab Republic (též Syria)'),(2022,806,'SB','Šalamounovy ostrovy','Solomon Islands'),(2023,11,'ES','Španělsko','Spain'),(2024,30,'SE','Švédsko','Sweden'),(2025,39,'CH','Švýcarsko','Switzerland'),(2026,82,'TJ','Tádžikistán','Tajikistan'),(2027,352,'TZ','Tanzanie','Tanzania (United Republic of)'),(2028,680,'TH','Thajsko','Thailand'),(2029,736,'TW','Tchaj-wan','Taiwan'),(2030,280,'TG','Togo','Togo'),(2031,839,'TK','Tokelau','Tokelau Islands'),(2032,817,'TO','Tonga','Tonga'),(2033,472,'TT','Trinidad a Tobago','Trinidad and Tobago'),(2034,212,'TN','Tunisko','Tunisia'),(2035,52,'TR','Turecko','Turkey'),(2036,80,'TM','Turkmenistán','Turkmenistan'),(2037,454,'TC','Turks a Caicos','Turks and Caicos Islands'),(2038,807,'TV','Tuvalu','Tuvalu'),(2039,350,'UG','Uganda','Uganda'),(2040,72,'UA','Ukrajina','Ukraine'),(2041,524,'UY','Uruguay','Uruguay'),(2042,81,'UZ','Uzbekistán','Uzbekistan'),(2043,834,'CX','Vánoční ostrov','Christmas Island'),(2044,816,'VU','Vanuatu','Vanuatu'),(2045,484,'VE','Venezuela','Venezuela'),(2046,690,'VN','Vietnam','Viet Nam'),(2047,626,'TL','Východní Timor','East Timor');
/*!40000 ALTER TABLE `cms_landcodes` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `cms_locales`
--

DROP TABLE IF EXISTS `cms_locales`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `cms_locales` (
  `locale_id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(45) COLLATE utf8_czech_ci DEFAULT NULL,
  `short` varchar(45) COLLATE utf8_czech_ci DEFAULT NULL,
  `class` varchar(45) COLLATE utf8_czech_ci DEFAULT NULL,
  PRIMARY KEY (`locale_id`),
  KEY `short` (`short`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8 COLLATE=utf8_czech_ci ROW_FORMAT=DYNAMIC COMMENT='Defined locales';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `cms_locales`
--

LOCK TABLES `cms_locales` WRITE;
/*!40000 ALTER TABLE `cms_locales` DISABLE KEYS */;
INSERT INTO `cms_locales` VALUES (1,'Čeština','czech','cz'),(2,'English','english','en');
/*!40000 ALTER TABLE `cms_locales` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `cms_menu`
--

DROP TABLE IF EXISTS `cms_menu`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `cms_menu` (
  `menu_id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `site_id` int(10) unsigned NOT NULL,
  `type` tinyint(3) DEFAULT NULL,
  `name` varchar(100) CHARACTER SET utf8 NOT NULL,
  `description` varchar(50) COLLATE utf8_czech_ci DEFAULT NULL,
  `visible` tinyint(1) unsigned NOT NULL DEFAULT '1',
  `order` tinyint(3) DEFAULT NULL,
  `parent` int(8) DEFAULT '0',
  PRIMARY KEY (`menu_id`),
  UNIQUE KEY `menu_id` (`menu_id`),
  KEY `site_id` (`site_id`),
  KEY `type` (`type`),
  KEY `visible` (`visible`),
  KEY `parent` (`parent`),
  KEY `order` (`order`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8 COLLATE=utf8_czech_ci ROW_FORMAT=DYNAMIC;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `cms_menu`
--

LOCK TABLES `cms_menu` WRITE;
/*!40000 ALTER TABLE `cms_menu` DISABLE KEYS */;
INSERT INTO `cms_menu` VALUES (1,1,1,'Home','Home',0,1,0),(2,2,1,'Blog','Simple Blog',1,2,0),(3,3,1,'About','About page',1,3,0);
/*!40000 ALTER TABLE `cms_menu` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `cms_sections`
--

DROP TABLE IF EXISTS `cms_sections`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `cms_sections` (
  `section_id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `title` varchar(100) COLLATE utf8_czech_ci DEFAULT NULL,
  `Description` varchar(150) COLLATE utf8_czech_ci DEFAULT NULL,
  `active` tinyint(1) unsigned DEFAULT '0',
  `key` varchar(45) COLLATE utf8_czech_ci NOT NULL,
  `return_error_code` int(3) unsigned DEFAULT '0',
  PRIMARY KEY (`section_id`),
  KEY `active` (`active`),
  KEY `title` (`title`),
  KEY `key` (`key`)
) ENGINE=InnoDB AUTO_INCREMENT=20 DEFAULT CHARSET=utf8 COLLATE=utf8_czech_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `cms_sections`
--

LOCK TABLES `cms_sections` WRITE;
/*!40000 ALTER TABLE `cms_sections` DISABLE KEYS */;
INSERT INTO `cms_sections` VALUES (1,'Central section','The central section',1,'central',404),(2,'Right panel','Right webpage Panel',0,'right',404),(3,'Left panel','The left webpage panel',0,'left',404),(4,'Header','The section above Central box',1,'header',404),(5,'API','API zero section',1,'api',404),(19,'Unibox','The central section',0,'centralní',400);
/*!40000 ALTER TABLE `cms_sections` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `cms_sessions`
--

DROP TABLE IF EXISTS `cms_sessions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `cms_sessions` (
  `user_id` int(8) NOT NULL DEFAULT '0',
  `session_id` varchar(45) COLLATE utf8_czech_ci NOT NULL,
  `session_data` text COLLATE utf8_czech_ci,
  `user_agent` varchar(150) COLLATE utf8_czech_ci DEFAULT NULL,
  `user_ip` varchar(45) COLLATE utf8_czech_ci DEFAULT NULL,
  `session_updated` int(11) NOT NULL,
  `session_expire` int(11) NOT NULL,
  `user_salt` varchar(45) COLLATE utf8_czech_ci DEFAULT NULL,
  KEY `user_id` (`user_id`),
  KEY `session_id` (`session_id`),
  KEY `user_agent` (`user_agent`),
  KEY `user_ip` (`user_ip`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_czech_ci COMMENT='Sessions table';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `cms_sessions`
--

LOCK TABLES `cms_sessions` WRITE;
/*!40000 ALTER TABLE `cms_sessions` DISABLE KEYS */;
/*!40000 ALTER TABLE `cms_sessions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `cms_sites`
--

DROP TABLE IF EXISTS `cms_sites`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `cms_sites` (
  `site_id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `parent_id` int(10) unsigned NOT NULL DEFAULT '0',
  `left_id` int(10) unsigned NOT NULL DEFAULT '0',
  `right_id` int(10) unsigned NOT NULL DEFAULT '0',
  `strict` tinyint(1) DEFAULT '0',
  `visible` tinyint(1) unsigned NOT NULL DEFAULT '0',
  `link` varchar(100) COLLATE utf8_czech_ci NOT NULL,
  `title` varchar(120) COLLATE utf8_czech_ci NOT NULL DEFAULT '',
  `html_title` varchar(120) COLLATE utf8_czech_ci NOT NULL DEFAULT '',
  `html_description` varchar(170) COLLATE utf8_czech_ci NOT NULL DEFAULT '',
  `html_keywords` varchar(255) COLLATE utf8_czech_ci NOT NULL,
  `acl` int(1) DEFAULT '0',
  PRIMARY KEY (`site_id`),
  KEY `left_id` (`left_id`),
  KEY `parent_id` (`parent_id`),
  KEY `right_id` (`right_id`),
  KEY `visible` (`visible`),
  KEY `grouped` (`strict`) USING BTREE,
  KEY `link` (`link`),
  KEY `title` (`title`)
) ENGINE=InnoDB AUTO_INCREMENT=10 DEFAULT CHARSET=utf8 COLLATE=utf8_czech_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `cms_sites`
--

LOCK TABLES `cms_sites` WRITE;
/*!40000 ALTER TABLE `cms_sites` DISABLE KEYS */;
INSERT INTO `cms_sites` VALUES (1,1,1,0,1,1,'/','Wbengine','Wbengine','This is Wbengine skeleton application example','wbengine,php,oop',0),(2,1,4,5,1,1,'/blog/','Simple Blog','The Simple Blog','This is a simple blog example','simple,blog',0),(3,1,4,5,1,1,'/about/','About box','The About box example','This is an about static html box example','about,box',0),(7,0,0,0,1,1,'/login/','Login','Login','Login','login',0),(8,1,1,1,0,1,'/api/','API','Api','Api','Api',1),(9,1,1,1,1,1,'/profile/','User\'s Profile','User\'s Profile','User\'s Profile','user,profile',1);
/*!40000 ALTER TABLE `cms_sites` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `cms_submenu`
--

DROP TABLE IF EXISTS `cms_submenu`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `cms_submenu` (
  `submenu_id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `menu_id` int(10) unsigned NOT NULL DEFAULT '0',
  `site_id` int(10) unsigned NOT NULL DEFAULT '0',
  `parent` int(10) unsigned DEFAULT '0',
  `title` varchar(100) CHARACTER SET utf8 NOT NULL,
  `locale` tinyint(3) unsigned DEFAULT '0',
  `menuorder` tinyint(3) unsigned NOT NULL DEFAULT '0',
  `visible` tinyint(1) unsigned DEFAULT '0',
  PRIMARY KEY (`submenu_id`),
  KEY `menu_id` (`menu_id`),
  KEY `site_id` (`site_id`),
  KEY `parent` (`parent`),
  KEY `locale` (`locale`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_czech_ci ROW_FORMAT=DYNAMIC;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `cms_submenu`
--

LOCK TABLES `cms_submenu` WRITE;
/*!40000 ALTER TABLE `cms_submenu` DISABLE KEYS */;
/*!40000 ALTER TABLE `cms_submenu` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `cms_users`
--

DROP TABLE IF EXISTS `cms_users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `cms_users` (
  `user_id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `user_type` int(1) DEFAULT '2',
  `group_id` int(10) unsigned NOT NULL DEFAULT '0',
  `username` varchar(150) COLLATE utf8_czech_ci NOT NULL,
  `firstname` varchar(45) COLLATE utf8_czech_ci DEFAULT NULL,
  `lastname` varchar(150) COLLATE utf8_czech_ci DEFAULT NULL,
  `password` varchar(50) COLLATE utf8_czech_ci NOT NULL DEFAULT '0',
  `email` varchar(100) COLLATE utf8_czech_ci DEFAULT NULL,
  `age` int(10) DEFAULT '0',
  `sex` tinyint(1) DEFAULT '0',
  `ac_status` int(1) unsigned zerofill NOT NULL DEFAULT '0',
  `ac_key` varchar(45) COLLATE utf8_czech_ci DEFAULT NULL,
  `address` varchar(100) COLLATE utf8_czech_ci DEFAULT NULL,
  `city` varchar(100) COLLATE utf8_czech_ci DEFAULT NULL,
  `postcode` varchar(45) COLLATE utf8_czech_ci DEFAULT NULL,
  `country` int(10) unsigned DEFAULT '0',
  `ac_active` int(10) unsigned DEFAULT '0',
  `user_ip` varchar(45) COLLATE utf8_czech_ci DEFAULT NULL,
  `locale` tinyint(1) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`user_id`),
  UNIQUE KEY `user_id` (`user_id`),
  KEY `user_type` (`user_type`),
  KEY `group_id` (`group_id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8 COLLATE=utf8_czech_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `cms_users`
--

LOCK TABLES `cms_users` WRITE;
/*!40000 ALTER TABLE `cms_users` DISABLE KEYS */;
INSERT INTO `cms_users` VALUES (0,0,1,'ANONYMOUS','Anonymní','Uživatel','0',NULL,0,0,0,NULL,NULL,NULL,NULL,0,0,NULL,1),(1,2,0,'Bajtlamer','Radek','Roža','89d808f87913189d092ff58e16149c3e','bajt@volny.cz',0,0,0,NULL,NULL,NULL,NULL,0,0,NULL,0);
/*!40000 ALTER TABLE `cms_users` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2018-07-10 20:35:18

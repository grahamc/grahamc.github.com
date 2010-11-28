#!/usr/bin/env php
<?php
chdir(dirname(__FILE__));

$xml = open_xml();
foreach (read_digest('../_site/DIGEST') as $file) {
    $xml .= build_block('http://grahamc.com' . $file);
}
$xml .= close_xml();

file_put_contents('../_site/sitemap.xml', $xml);

function read_digest($file) {
    $raw = @file($file);
    
    if (!$raw) {
        echo "DIGEST does not exist or is empty." . PHP_EOL;
        exit(1);
    }
    
    $files = array();
    foreach ($raw as $line) {
        $line = trim($line);
        
        // Remove the . from the beginning
        $line = substr($line, 1);
        
        // Ignore all the non-HTML files
        if (strpos($line, 'html') === false) {
            continue;
        }
        
        // If its the index, report the directory
        if (substr($line, -11) === '/index.html') {
            $files[] = substr($line, 0, -10);
        } else {
            $files[] = $line;
        }
    }
    
    return $files;
}


function build_block($loc) {
    return '    <url>
      <loc>' . $loc  . '</loc>
      <lastmod>' . date('c') . '</lastmod>
      <changefreq>weekly</changefreq>
    </url>' . PHP_EOL;
}

function open_xml() {
    $xml = '<?xml version="1.0" encoding="UTF-8"?>
<urlset
      xmlns="http://www.sitemaps.org/schemas/sitemap/0.9"
      xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
      xsi:schemaLocation="http://www.sitemaps.org/schemas/sitemap/0.9
            http://www.sitemaps.org/schemas/sitemap/0.9/sitemap.xsd">';
    $xml .= PHP_EOL;
    return $xml;
}

function close_xml() {
    return '</urlset>' . PHP_EOL;
}

/*
<?xml version="1.0" encoding="UTF-8"?>
<urlset
      xmlns="http://www.sitemaps.org/schemas/sitemap/0.9"
      xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
      xsi:schemaLocation="http://www.sitemaps.org/schemas/sitemap/0.9
            http://www.sitemaps.org/schemas/sitemap/0.9/sitemap.xsd">
<url>
  <loc>http://grahamc.com/</loc>
  <lastmod>2010-11-27T23:25:54+00:00</lastmod>
  <changefreq>weekly</changefreq>
</url>
<url>
  <loc>http://grahamc.com/feed/</loc>
  <lastmod>2010-11-27T23:25:53+00:00</lastmod>
  <changefreq>weekly</changefreq>
</url>
</urlset>
*/
#!/usr/bin/env php
<?php

if (empty($argv[1])) {
    die('You must specify a file!');
}

$file = $argv[1];

if (is_dir($file)) {
    die('The file to parse must be a regular file');
}

$content = file_get_contents($file);

if (empty($content)) {
    die('File is empty nothing to do ;)');
}

$content = html_entity_decode($content);

$doc = new DOMDocument('1.0');
$doc->preserveWhiteSpace = false;
$doc->formatOutput = true;
$doc->loadXML($content);

echo $doc->saveXML();

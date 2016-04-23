#!/usr/bin/env php
<?php

if (empty($argv[1])) {
    die('You must specify a file!');
}

$file = $argv[1];

if (!is_readable($file)) {
    die('File is missing or is not readable!');
}

$content = file_get_contents($file);

if (empty($content)) {
    die('File is empty nothing to do ;)');
}

$content = html_entity_decode($content);

$content = preg_replace('/^s:\d+:"|";$/', '', $content);

$doc = new DOMDocument('1.0');
$doc->preserveWhiteSpace = false;
$doc->formatOutput = true;
$doc->loadXML($content, LIBXML_NOENT);

echo $doc->saveXML();

<?php

/**
 * This script adds tools JSON to tools json file
 */

$steamDir = $argv[1];

$addJson = __DIR__.'/../Gamefilemod_src/core.json';
$smJson = $steamDir.'/Data/Tools/ToolSets/core.json';

$oldObject = json_decode(file_get_contents($smJson), true);
$addObject = json_decode(file_get_contents($addJson), true);
$newObject = array_merge_recursive($oldObject, $addObject);

$newJson = json_encode($newObject, JSON_PRETTY_PRINT);

file_put_contents(__DIR__.'/../Gamefilemod/Data/Tools/ToolSets/core.json', $newJson);

echo 'Built Tools\ToolSets\core.json'.PHP_EOL;

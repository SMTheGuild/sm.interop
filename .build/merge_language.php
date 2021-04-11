<?php

/**
 * This script adds tools JSON to tools json file
 */

$steamDir = $argv[1];

$addDir = __DIR__.'/../Gamefilemod_src/Language';
$smDir = $steamDir.'/Data/Gui/Language';
$targetDir = __DIR__.'/../Gamefilemod/Data/Gui/Language';

foreach (glob($addDir.'/*', GLOB_ONLYDIR) as $dir)
{
    $language = basename($dir);

    $smJson = $smDir.'/'.$language.'/InventoryItemDescriptions.json';
    $addJson = $addDir.'/'.$language.'/InventoryItemDescriptions.json';

    $oldObject = json_decode(file_get_contents($smJson), true);
    $addObject = json_decode(file_get_contents($addJson), true);
    $newObject = array_merge_recursive($oldObject, $addObject);

    $newJson = json_encode($newObject, JSON_PRETTY_PRINT);

    $savePath = $targetDir.'/'.$language.'/InventoryItemDescriptions.json';
    $saveDir = dirname($savePath);
    if (!is_dir($saveDir))
    {
        echo $saveDir.PHP_EOL;
        mkdir($saveDir, 0777, true);
    }

    file_put_contents($savePath, $newJson);
}

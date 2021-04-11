<?php

$smDir = $argv[1];

$thisScriptsDir = realpath(__DIR__.'/../Gamefilemod_src/Scripts');
$smScriptsDir = $smDir.'/Data/Scripts';
$files = rglob($thisScriptsDir.'/*.lua');
foreach ($files as $file)
{
    $fileName = substr($file, strlen($thisScriptsDir) + 1);
    $originalPath = $smScriptsDir.'/'.$fileName;
    $original = file_get_contents($originalPath);
    $append = file_get_contents($file);
    $savePath = __DIR__.'/../Gamefilemod/Data/Scripts/'.$fileName;
    $saveDir = dirname($savePath);
    if (!is_dir($saveDir))
        mkdir($saveDir, 0777, true);
    file_put_contents($savePath, $original . PHP_EOL . $append);
    echo 'Appended '.$fileName.PHP_EOL;
}

function rglob($pattern, $flags = 0) {
    $files = glob($pattern, $flags);
    foreach (glob(dirname($pattern).'/*', GLOB_ONLYDIR|GLOB_NOSORT) as $dir) {
        $files = array_merge($files, rglob($dir.'/'.basename($pattern), $flags));
    }
    return $files;
}

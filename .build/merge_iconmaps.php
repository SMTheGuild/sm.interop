<?php

/**
 * This script pastes the IconMap addition into the current game version's IconMap.png and IconMap.xml
 */

$steamDir = $argv[1];
$smDirIconMapXml = $steamDir.'\Data\Gui\IconMap.xml';
$smDirIconMapPng = $steamDir.'\Data\Gui\IconMap.png';

$thisIconPng = __DIR__.'/../Gamefilemod_src/IconMap_Addition.png';

// 1. Find max coordinates
$maxX = 0;
$maxY = 0;

$xml = simplexml_load_file($smDirIconMapXml);
$group = $xml->Resource->Group;
[$iconSizeX, $iconSizeY] = explode(' ', (string) $group->attributes()->size);

foreach ($group->Index as $index)
{
    $frame = $index->Frame;
    $point = (string) $frame->attributes()->point;
    [$x, $y] = explode(' ', $point);
    if ($y > $maxY)
    {
        $maxY = $y;
        $maxX = $x;
    }
    elseif ($y == $maxY && $x > $maxX)
    {
        $maxX = $x;
    }
}

// 2. Load image and find new coordinates
$originalIconMap = imagecreatefrompng($smDirIconMapPng);
$width = imagesx($originalIconMap);
$height = imagesy($originalIconMap);

$newX = $maxX + $iconSizeX;
$newY = $maxY;
if ($newX + $iconSizeX > $width)
{
    $newX = 0;
    $newY = $maxY + $iconSizeY;
}
$newHeight = max($height, $newY + $iconSizeY);

// 3. Add icon to IconMap.png for modded tool and save
$newIcon = imagecreatefrompng($thisIconPng);
$newIconMap = imagecreatetruecolor($width, $newHeight);
imagesavealpha($newIconMap, true);
$color = imagecolorallocatealpha($newIconMap, 0, 0, 0, 127);
imagefill($newIconMap, 0, 0, $color);
imagecopy($newIconMap, $originalIconMap, 0, 0, 0, 0, $width, $height);
imagecopy($newIconMap, $newIcon, $newX, $newY, 0, 0, $iconSizeX, $iconSizeY);

imagepng($newIconMap, __DIR__.'/../Gamefilemod/Data/Gui/IconMap.png');
imagedestroy($newIconMap);

// 4. Add entry to IconMap.xml for modded tool and save
$newIndex = $group->addChild('Index');
$newIndex->addAttribute('name', 'e74ff990-adac-434f-9967-bf9833d0bd69');
$newFrame = $newIndex->addChild('Frame');
$newFrame->addAttribute('point', $newX .' '. $newY);

$xml->asXml(__DIR__.'/../Gamefilemod/Data/Gui/IconMap.xml');

echo 'Built new IconMap.png and IconMap.xml'.PHP_EOL;

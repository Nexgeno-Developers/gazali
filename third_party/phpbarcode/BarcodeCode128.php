<?php
/**
 * Code 128 Barcode Generator (Code Set B)
 * Generates 1D barcode PNG with human-readable text below.
 * Standalone, no Composer required. Uses GD.
 *
 * Based on ISO/IEC 15417 Code 128 encoding.
 */

class BarcodeCode128
{
    /** Code 128 symbol widths: 6 digits = bar,space,bar,space,bar,space (1-4 modules each) */
    private static $patterns = [
        '212222', '222122', '222221', '121223', '121322', '131222', '122213', '122312', '132212', '221213',
        '221312', '231212', '112232', '122132', '122231', '113222', '123122', '123221', '223211', '221132',
        '221231', '213212', '223112', '312131', '311222', '321122', '321221', '312212', '322112', '322211',
        '212123', '212321', '232121', '111323', '131123', '131321', '112313', '132113', '132311', '211313',
        '231113', '231311', '112133', '112331', '132131', '113123', '113321', '133121', '313121', '211331',
        '231131', '213113', '213311', '213131', '311123', '311321', '331121', '312113', '312311', '332111',
        '314111', '221411', '431111', '111224', '111422', '121124', '121421', '141122', '141221', '112214',
        '112412', '122114', '122411', '142112', '142211', '241211', '221114', '413111', '241112', '134111',
        '111242', '121142', '121241', '114212', '124112', '124211', '411212', '421112', '421211', '212141',
        '214121', '412121', '111143', '111341', '131141', '114113', '114311', '411113', '411311', '113141',
        '114131', '311141', '411131', '211412', '211214', '211232', '233111'   // 100-106: special, Start A/B/C, Stop
    ];

    const START_B = 104;
    const STOP = 106;

    /**
     * Encode string for Code 128 B (ASCII 32-126).
     * Returns array of symbol values (including start, data, checksum, stop).
     */
    public static function encode($text)
    {
        $text = (string) $text;
        $codes = [self::START_B];
        $len = strlen($text);
        for ($i = 0; $i < $len; $i++) {
            $c = ord($text[$i]);
            if ($c >= 32 && $c <= 126) {
                $codes[] = $c - 32;
            } else {
                $codes[] = 0; // space as fallback
            }
        }
        $checksum = $codes[0];
        for ($i = 1, $n = count($codes); $i < $n; $i++) {
            $checksum += $i * $codes[$i];
        }
        $codes[] = $checksum % 103;
        $codes[] = self::STOP;
        return $codes;
    }

    /**
     * Get bar/space sequence (array of module widths: 1=bar, 0=space).
     * Returns flat array of 0s and 1s for drawing.
     */
    public static function getBarSequence($text)
    {
        $codes = self::encode($text);
        $seq = [];
        foreach ($codes as $idx => $code) {
            $pattern = self::$patterns[$code];
            $len = strlen($pattern);
            for ($i = 0; $i < $len; $i++) {
                $w = (int) $pattern[$i];
                $fill = ($i % 2 === 0) ? 1 : 0; // bar, space, bar, ...
                for ($j = 0; $j < $w; $j++) {
                    $seq[] = $fill;
                }
            }
            if ($code === self::STOP) {
                $seq[] = 1;
                $seq[] = 1;
            }
        }
        return $seq;
    }

    /**
     * Generate PNG image and save to file. Includes human-readable text below barcode.
     *
     * @param string $text   Data to encode
     * @param string $file   Path to save PNG
     * @param int    $width  Module width in pixels (bar/space thickness)
     * @param int    $height Bar height in pixels
     * @param int    $quiet  Quiet zone in modules (left/right)
     * @return bool Success
     */
    public static function savePng($text, $file, $width = 2, $height = 50, $quiet = 10)
    {
        if (!function_exists('imagecreatetruecolor')) {
            return false;
        }
        $seq = self::getBarSequence($text);
        $moduleW = (int) $width;
        $barH = (int) $height;
        $quietPx = $quiet * $moduleW;
        $barcodeWidth = count($seq) * $moduleW;
        $totalWidth = 2 * $quietPx + $barcodeWidth;
        $fontH = 14;
        $totalHeight = $barH + $fontH + 8;
        $img = imagecreatetruecolor($totalWidth, $totalHeight);
        if (!$img) {
            return false;
        }
        $white = imagecolorallocate($img, 255, 255, 255);
        $black = imagecolorallocate($img, 0, 0, 0);
        imagefill($img, 0, 0, $white);
        $x = $quietPx;
        foreach ($seq as $v) {
            if ($v === 1) {
                imagefilledrectangle($img, $x, 0, $x + $moduleW - 1, $barH - 1, $black);
            }
            $x += $moduleW;
        }
        $textY = $barH + 4;
        $font = 2;
        $textWidth = imagefontwidth($font) * strlen($text);
        $textX = (int) (($totalWidth - $textWidth) / 2);
        imagestring($img, $font, $textX, $textY, $text, $black);
        $ok = imagepng($img, $file);
        imagedestroy($img);
        return $ok;
    }
}

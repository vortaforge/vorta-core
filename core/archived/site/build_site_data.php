<?php
declare(strict_types=1);

/**
 * Build-time data generator for the GitHub Pages download page (index.html).
 *
 * GitHub Pages only serves static files, so PHP cannot run when a visitor opens
 * the page. Instead this script runs inside .github/workflows/pages.yml, asks
 * the GitHub API for the mods/ directory using the
 * workflow's GITHUB_TOKEN, and writes the result to data/site-data.json. The
 * page reads that file first (same origin, no rate limit) and only falls back
 * to calling the GitHub API from the browser if the file is missing or stale.
 *
 * Usage:   php scripts/site/build_site_data.php --out=_site/data/site-data.json
 * Env:     GITHUB_TOKEN       optional, raises the API rate limit; never printed
 *          GITHUB_REPOSITORY  optional, "owner/repo" (default vortaforge/core)
 * Exit:    0 on success, 1 on any API/IO failure (so a bad snapshot is never
 *          deployed over a good one).
 *
 * The filtering rules mirror modsFromContents() in
 * index.html and must be kept in sync with them.
 *
 * AI involvement: written with Claude (Anthropic) at the request of the
 * maintainer. See CREDITS.md.
 */

if (PHP_SAPI !== 'cli') {
    http_response_code(404);
    exit(1);
}

const EXCLUDED_MODS = ['TEMPLATE-MOD', 'datapack-fixer', 'rtwrapper-mod'];

function fail(string $message): never
{
    fwrite(STDERR, "build_site_data: {$message}\n");
    exit(1);
}

/** @return array{0:int,1:mixed} HTTP status and decoded JSON body */
function github_get(string $url, ?string $token): array
{
    $headers = [
        'Accept: application/vnd.github+json',
        'X-GitHub-Api-Version: 2022-11-28',
        'User-Agent: vortaforge-core-pages-build',
    ];
    if ($token !== null && $token !== '') {
        $headers[] = 'Authorization: Bearer ' . $token;
    }

    $lastError = 'unknown error';
    for ($attempt = 1; $attempt <= 3; $attempt++) {
        $ch = curl_init($url);
        curl_setopt_array($ch, [
            CURLOPT_RETURNTRANSFER => true,
            CURLOPT_HTTPHEADER => $headers,
            CURLOPT_CONNECTTIMEOUT => 10,
            CURLOPT_TIMEOUT => 30,
            CURLOPT_FOLLOWLOCATION => false,
            CURLOPT_PROTOCOLS => CURLPROTO_HTTPS,
        ]);
        $body = curl_exec($ch);
        $status = (int) curl_getinfo($ch, CURLINFO_RESPONSE_CODE);
        $curlError = curl_error($ch);
        curl_close($ch);

        if ($body === false) {
            $lastError = "network error ({$curlError})";
        } elseif ($status >= 500 || $status === 429) {
            $lastError = "HTTP {$status}";
        } else {
            $decoded = json_decode((string) $body, true);
            if ($status === 404) {
                return [404, null];
            }
            if ($status < 200 || $status >= 300) {
                $hint = ($status === 403 || $status === 429)
                    ? ' (API rate limit or blocked request; set GITHUB_TOKEN)'
                    : '';
                fail("GET {$url} returned HTTP {$status}{$hint}");
            }
            if ($decoded === null && json_last_error() !== JSON_ERROR_NONE) {
                fail("GET {$url} returned invalid JSON");
            }
            return [$status, $decoded];
        }
        if ($attempt < 3) {
            sleep($attempt * 2);
        }
    }
    fail("GET {$url} failed after 3 attempts: {$lastError}");
}



/** @param mixed $items */
function mods_from_contents($items): array
{
    if (!is_array($items)) {
        return [];
    }
    $mods = [];
    foreach ($items as $item) {
        if (!is_array($item) || ($item['type'] ?? null) !== 'dir') {
            continue;
        }
        $name = $item['name'] ?? null;
        if (!is_string($name) || in_array($name, EXCLUDED_MODS, true)
            || !preg_match('/^[A-Za-z0-9._-]+$/', $name)) {
            continue;
        }
        $mods[] = ['name' => $name, 'dir' => $name];
    }
    usort($mods, static fn(array $a, array $b): int => strcmp($a['name'], $b['name']));
    return $mods;
}

// ---------------------------------------------------------------------------

$options = getopt('', ['out:']);
$out = $options['out'] ?? null;
if (!is_string($out) || $out === '') {
    fail('missing --out=<path>');
}

$repository = getenv('GITHUB_REPOSITORY') ?: 'vortaforge/core';
if (!preg_match('#^[A-Za-z0-9_.-]+/[A-Za-z0-9_.-]+$#', $repository)) {
    fail('GITHUB_REPOSITORY is not in owner/repo form');
}
$token = getenv('GITHUB_TOKEN') ?: null;
$api = "https://api.github.com/repos/{$repository}";

// Datapacks are retired (2026-11-05). The page no longer requests any release,
// so the snapshot must not query one either: doing so published pack download
// URLs into _site/data/, which is exactly the data the retirement removed from
// the page. The retired packs remain readable in archived/packs and registered
// in archived/archive.json.

[$status, $contents] = github_get($api . '/contents/mods', $token);
if ($status === 404) {
    fail('mods/ not found in the repository');
}
$mods = mods_from_contents($contents);
if (count($mods) === 0) {
    fail('mods/ contained no mod directories; refusing to publish an empty list');
}

$snapshot = [
    'schemaVersion' => 1,
    'generatedAt' => gmdate('c'),
    'repository' => $repository,
    'datapacksRetired' => true,
    'mods' => $mods,
];

$json = json_encode($snapshot, JSON_PRETTY_PRINT | JSON_UNESCAPED_SLASHES | JSON_UNESCAPED_UNICODE | JSON_THROW_ON_ERROR);

$dir = dirname($out);
if (!is_dir($dir) && !mkdir($dir, 0755, true) && !is_dir($dir)) {
    fail("cannot create directory {$dir}");
}
$tmp = $out . '.tmp';
if (file_put_contents($tmp, $json . "\n") === false || !rename($tmp, $out)) {
    fail("cannot write {$out}");
}

fwrite(STDOUT, sprintf(
    "build_site_data: wrote %s (%d mods; datapacks retired, no pack data emitted)\n",
    $out,
    count($mods)
));

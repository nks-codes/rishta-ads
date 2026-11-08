<?php
/**
 * Biah.pk Rishta Classifieds API
 * Version: 1.0
 * Endpoint: GET /ads/api/v1/cities.php
 *
 * Public list of the distinct cities of approved, unexpired advertisements.
 * Uses the same conditions as ads.php. Returns no private information.
 */

require_once __DIR__ . '/../../../includes/bootstrap.php';

function adsCitiesResponse(int $statusCode, array $data): void
{
    http_response_code($statusCode);

    header('Content-Type: application/json; charset=utf-8');
    header('Cache-Control: no-store, no-cache, must-revalidate');
    header('X-Content-Type-Options: nosniff');

    echo json_encode(
        $data,
        JSON_UNESCAPED_UNICODE |
        JSON_UNESCAPED_SLASHES |
        JSON_INVALID_UTF8_SUBSTITUTE
    );

    exit;
}

// This endpoint only accepts GET requests.
if ($_SERVER['REQUEST_METHOD'] !== 'GET') {
    header('Allow: GET');

    adsCitiesResponse(405, [
        'success' => false,
        'message' => 'Method not allowed.'
    ]);
}

try {

    // LIMIT is only a safety ceiling; real city counts are far lower.
    $stmt = $pdo->query("
        SELECT DISTINCT city
        FROM rishta_ads
        WHERE status = 'approved'
          AND expires_at > NOW()
          AND city <> ''
        ORDER BY city ASC
        LIMIT 1000
    ");

    $cities = $stmt->fetchAll(PDO::FETCH_COLUMN);

    adsCitiesResponse(200, [
        'success' => true,
        'message' => 'Cities retrieved successfully.',
        'data' => array_values($cities)
    ]);

} catch (Throwable $e) {

    error_log(
        'Biah Ads API cities error: ' . $e->getMessage()
    );

    adsCitiesResponse(500, [
        'success' => false,
        'message' => 'Unable to retrieve cities right now.'
    ]);
}

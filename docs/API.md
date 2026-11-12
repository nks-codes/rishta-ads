# Rishta Ads – API reference

Base URL: `https://biah.pk/ads/api/v1/`

All responses are JSON with `success` (bool) and `message` (string).
Errors use a non-2xx HTTP status and `success: false`; the app shows `message`.
The server uses **PHP sessions** for rate limits, so the app stores the session
cookie (encrypted) and sends it with every request.

## GET `ads.php` – public listing
Query parameters (all optional): `page`, `limit` (max 50), `city` (exact match),
`gender` (`Male`/`Female`), `marital_status` (`Never Married`/`Divorced`/`Widowed`),
`min_age`, `max_age` (18–100).

Response: `pagination { current_page, per_page, total_ads, total_pages }` and
`data[]` of `{ id ("RCA-000123"), text, city, gender, age, marital_status,
created_at, expires_at, days_left }`. Phone numbers are never returned.

## GET `cities.php` – city list (added for the app)
Source: `server/cities.php` in this repository (upload to the API folder).
Returns `data`: array of distinct cities of approved, unexpired ads.

## POST `submit.php` – submit an ad (JSON body)
Required: `ad_text` (1–300 chars), `city` (≤100 bytes), `gender`, `age` (18–100),
`marital_status`, `phone_number` (digits, `+ ( ) . -` and spaces; ≤30),
`phone_consent` (true/false). Optional: `contact_name` (≤100 bytes),
`contact_email` (valid, ≤190 bytes).

Success: HTTP 201, `data { id, status: "pending", expires_at }`.
Server cooldown: 30 seconds per PHP session (HTTP 429).

## POST `reveal-phone.php` – reveal a phone number (JSON body)
Body: `{ "ad_id": "RCA-000123" }`.
Success: `data { ad_id, phone_number }`.
404 = number unavailable (not approved, expired, or no consent).
Server limit: 15 requests per 5 minutes per PHP session (HTTP 429).

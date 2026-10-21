# Israeli gov-data mirrors: verified notes (2026-10-22, from the box, plain curl, no auth)

## over.org.il ("גרסאות לעם")
Tracks government datasets (data.gov.il CKAN, govmap layers, PowerBI visuals and others) and stores every version as a snapshot. Only things I tested are listed here.

- UI: `https://over.org.il/versions/{dataset_uuid}` is a React SPA. The HTML holds only SEO meta plus JSON-LD (title, creator, `sameAs` = source URL, `dateModified`), so use the API.
- `GET /api/v1/datasets?limit=500&offset=N` returns `{total, items[]}`, with 4718 datasets at test time. Each item has id, title, ckan_id, ckan_name, source_type (ckan|govmap|...), source_url, last_polled_at, last_modified, version_count and versions_url.
  - Filters documented in the JS bundle: organization_id, tag/tag_id, status, ckan_id (matches data.gov.il UUID or slug), limit (1-500), offset.
  - `q`, `search`, `title`, `source_type` and `ckan_name` were tested and **ignored** (total stays 4718). No server-side text search was confirmed. To search, page through everything and filter titles client-side.
- `GET /api/v1/datasets/{id}` returns metadata.
- `GET /api/v1/datasets/{id}/versions` returns a list of versions (version_number, detected_at UTC, change_summary, `resources[].download_url`).
- `GET /api/v1/datasets/{id}/versions/latest` and `/versions/{number}` also work.
- Resource files are on public R2: `https://pub-63c02556dabd4956af9500eb8fe7198c.r2.dev/datasets/{id}/v1/{hash}_geojson.gz` (gzipped GeoJSON in CRS84, with a `metadata` block: govmap layer_id, scraped_at, fields), plus `_csv` and `_symbology.zip`.
- `GET /api/versions/{version_id}/download.zip` returned HTTP 200.
- `GET /api/v1/organizations` returns the org list.
- `GET /api/tables` lists SQL-queryable tables (dataset_id, version_id, source_url).
- Other API families referenced in the bundle, not tested: /api/tables/sql, /api/tables/{t}/features?bbox=, /api/append/{id}/(rows|schema|sql|datastore_search_sql|download.csv), /api/deals/*, /api/nadlan/*, /api/prices/*, /api/cbs/*, /api/knesset-db/*, /api/deep-search/*, /api/ocal/*.
- Example: municipal boundaries, govmap layer 125 "רשויות מקומיות" = dataset `53d1b1e3-e65c-4320-a1f9-19cff3067020`. It has 411 features with fields muni_heb, muni_eng, sug_muni, cr_pnim, machoz and hearot ("השכבה אינה סטטוטורית באופן מלא"). Hadera has a separate layer: `8e8d6863-c284-4374-a6bd-e6c825ab0490` (govmap lay=240433).

## data.gov.il CKAN
- `https://data.gov.il/api/3/action/package_search?q=...&rows=N` returns HTTP 200 from the box, not blocked, with or without a browser User-Agent. Use `curl -G --data-urlencode` for Hebrew.
- "גבולות שיפוט" gives 0 results. "גבולות" gives 21 results (police, fire, cadastre, plans, CBS statistical areas 2008), and **none of them is municipal jurisdiction boundaries**. "מועצות אזוריות" and "רשויות מקומיות" return only tabular data (financial reports etc.).

## odata.org.il (Hasadna CKAN)
- `https://www.odata.org.il/api/3/action/package_search?q=...` works (standard CKAN). The query "רשויות מקומיות" returned 297 results.

## Other Hasadna endpoints reachable (HTTP status only, not explored)
- https://next.obudget.org/ returned 200, https://data.obudget.org/ returned 301, https://open-bus-stride-api.hasadna.org.il/docs returned 200.

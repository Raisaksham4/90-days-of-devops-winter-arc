# Day 07 — HTTP/HTTPS and Git/GitHub

Completed on 8 October 2026. Week 1, Day 7 of the 90-Day DevOps Winter Arc.

## What I built and tested

Built a small Python notes API using `http.server` and tested requests with `curl`. Inspected an HTTPS server certificate with OpenSSL, then published the lab through feature branches and GitHub pull requests.

## Files

- [`http_api.py`](./http_api.py): an in-memory notes API bound to `127.0.0.1:8080`.
- [`public/index.html`](./public/index.html): a page for the earlier static-server exercise.

## Run the API

From this repository's root, run the server in one terminal:

```bash
python3 Day-07/http_api.py
```

Use another terminal for the requests below. Restarting the API resets the notes. Run the sequence once from a fresh server.

```bash
curl -i http://127.0.0.1:8080/notes

curl -i -X POST http://127.0.0.1:8080/notes \
  -H "Content-Type: application/json" \
  -d '{"text":"Test POST request"}'

curl -i -X PUT http://127.0.0.1:8080/notes/1 \
  -H "Content-Type: application/json" \
  -d '{"text":"Updated with PUT"}'

curl -i -X DELETE http://127.0.0.1:8080/notes/1
curl -i http://127.0.0.1:8080/unknown
```

## Observed HTTP results

| Request | Observed response |
|---|---|
| `GET /notes` | `200 OK`; JSON notes list |
| `POST /notes` | `201 Created`; new note with ID 2 |
| `PUT /notes/1` | `200 OK`; updated note text |
| `DELETE /notes/1` | `204 No Content`; empty response body |
| `GET /unknown` | `404 Not Found`; JSON error |
| POST to the earlier Python static server | `501 Unsupported method ('POST')` |

Inspected the status line, `Server`, `Date`, and `Content-Type` headers alongside the response body. `curl -i` includes response headers; `-H` sets a request header; `-d` supplies the request body.

The initial static server did not implement POST. The custom API implemented the method handlers and returned the expected responses in the tested sequence.

An external HTTP request to `google.com` returned a 301 redirect. HTTPS requests initially failed with curl error 35 (connection reset), and a later request to `https://example.com` returned HTTP/2 200. The reset's cause was not established.

## TLS certificate inspection

```bash
openssl s_client -connect example.com:443 -servername example.com </dev/null 2>/dev/null \
  | openssl x509 -noout -subject -issuer -dates
```

Observed certificate fields:

```text
subject=CN=example.com
issuer=C=US, O=SSL Corporation, CN=Cloudflare TLS Issuing ECC CA 3
notBefore=Sep 26 22:49:11 2026 GMT
notAfter=Dec 25 22:56:35 2026 GMT
```

`-servername` sends the SNI hostname. This command inspects the presented certificate. Its output alone does not establish successful certificate-chain or hostname validation; verification diagnostics were redirected away.

## Git/GitHub workflow completed

```text
main → feature branch → stage → commit → push → pull request → merge → sync main
```

| Pull request | Change | Result |
|---|---|---|
| [#1](https://github.com/Raisaksham4/90-days-of-devops-winter-arc/pull/1) | Notes API, static page and initial README | Merged |
| [#2](https://github.com/Raisaksham4/90-days-of-devops-winter-arc/pull/2) | TLS certificate inspection notes | Merged |
| [#3](https://github.com/Raisaksham4/90-days-of-devops-winter-arc/pull/3) | Progress tracker updated to 7/90 | Merged |

Practised `git switch`, `git add`, `git commit`, `git push -u`, `gh pr create`, `gh pr merge`, and `git pull --ff-only`. A clean final status showed `main...origin/main`. These were self-managed lab pull requests; independent teammate review was not demonstrated.

## Troubleshooting notes

- Detected an accidental deletion of the root README and restored it before staging the Day 7 work.
- `git switch -c` failed when a branch already existed; switched to the existing branch instead.
- An initial `sed` replacement did not match the actual progress line, so no change was committed and GitHub rejected the PR with `No commits between main and day-07-progress-update`. Corrected the pattern, committed and pushed the real change, then merged PR #3.

## Validation and scope

- Python syntax check passed with `python3 -m py_compile Day-07/http_api.py`.
- `git diff --cached --check` passed before commits.
- HTTP results and merged PRs were captured in screenshots.

This is a learning API with in-memory storage, fixed `/notes/1` update/delete handlers and no input validation or authentication. Repeated deletion, malformed input and persistent storage were not tested. The local API uses HTTP; the TLS exercise inspected an external HTTPS endpoint.

## Evidence

Detailed notes and the supplied screenshots are recorded in the Day 7 Notion entry. The LinkedIn draft uses five screenshots covering API results, TLS inspection and the pull request workflow.

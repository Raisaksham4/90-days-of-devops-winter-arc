# Day 07 — HTTP/HTTPS and Git/GitHub

## Hands-on HTTP API lab

Created a Python API server with `http.server` and tested it using `curl`.

| Request | Result |
|---|---|
| `GET /notes` | `200 OK` |
| `POST /notes` | `201 Created` |
| `PUT /notes/1` | `200 OK` |
| `DELETE /notes/1` | `204 No Content` |
| `GET /unknown` | `404 Not Found` |
| POST to Python static server | `501 Unsupported Method` |

## Commands used

```bash
curl -i http://127.0.0.1:8080/notes
curl -i -X POST http://127.0.0.1:8080/notes \
  -H "Content-Type: application/json" \
  -d '{"text":"Test POST request"}'
curl -i -X PUT http://127.0.0.1:8080/notes/1 \
  -H "Content-Type: application/json" \
  -d '{"text":"Updated with PUT"}'
curl -i -X DELETE http://127.0.0.1:8080/notes/1


## TLS certificate check

```bash
openssl s_client -connect example.com:443 -servername example.com </dev/null 2>/dev/null \
  | openssl x509 -noout -subject -issuer -dates

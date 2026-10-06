# Day 05/90 — DNS, HTTP/HTTPS, Nginx and a 502 Incident

**Date:** October 6, 2026  
**Environment:** Ubuntu 26.04 in WSL  
**Status:** Main assignment completed

## Goal

Follow a request from name resolution to a local application through Nginx, then deliberately break the upstream and diagnose the resulting 502.

## What I learned

- DNS maps a hostname to addresses. A recursive resolver queries the DNS hierarchy and caches answers for their TTL.
- `A` records return IPv4 addresses; `AAAA` records return IPv6 addresses. `NS`, `MX`, `CNAME`, `TXT`, and `PTR` records serve other purposes.
- An HTTP client sends a request and receives a status, headers, and usually a body. HTTPS carries HTTP over TLS, which encrypts traffic and validates the server certificate.
- Nginx can receive a request on port 80 and forward it to an upstream application on another port.
- A 502 from the proxy can mean the proxy is healthy but cannot contact its upstream.

## 1. DNS

```bash
dig example.com
dig +short example.com
getent hosts example.com
getent ahosts example.com
```

The `dig` A lookup returned `172.66.147.243` and `104.20.23.154`; `+short` printed only those addresses. `getent hosts` returned an IPv6 address, while `getent ahosts` showed both IPv4 and IPv6 results. The addresses are observations from this run and may change.

`dig` asks DNS directly. `getent` follows the operating system's configured name resolution. A hostname is the human-readable name; an IP address identifies a network endpoint. A resolver finds the address for the name.

## 2. HTTP and HTTPS

```bash
curl http://example.com
curl -I http://example.com
curl -v http://example.com
openssl s_client -connect example.com:443 -servername example.com
```

The HTTP request returned `HTTP/1.1 200 OK`, `Content-Type: text/html; charset=utf-8`, and `Server: cloudflare`. The verbose trace showed name resolution, an unsuccessful IPv6 connection attempt on this WSL setup, a successful IPv4 connection to port 80, `GET / HTTP/1.1`, and the response.

The TLS inspection connected on port 443, showed a certificate for `example.com`, negotiated TLS 1.3 with `TLS_AES_256_GCM_SHA384`, and reported `Verification: OK` / `Verify return code: 0 (ok)`. HTTPS uses TLS to protect the connection and authenticate the server. Port 443 is the conventional HTTPS port.

## 3. Local application and reverse proxy

Nginx was installed but initially `inactive (dead)`. I started it and confirmed `active (running)`, listeners on `0.0.0.0:80` and `[::]:80`, and `HTTP/1.1 200 OK` from `curl -I http://127.0.0.1`.

The test application served `Hello from Day 5 App` on port 3000:

```bash
mkdir -p ~/day5-app
cd ~/day5-app
echo 'Hello from Day 5 App' > index.html
python3 -m http.server 3000
```

A direct `curl http://127.0.0.1:3000` returned the message. I configured an Nginx server block for `day5.local` and enabled it. `sudo nginx -t` reported successful syntax and the request with `Host: day5.local` returned `200 OK` through Nginx.

The reusable configuration is in [nginx/day5.conf](nginx/day5.conf). The application page is in [app/index.html](app/index.html). For a local-only reproduction, bind the Python server to `127.0.0.1` rather than its default `0.0.0.0`.

## 4. Local hostname

I added `127.0.0.1 day5.local` to `/etc/hosts`. `getent hosts day5.local` returned `127.0.0.1), and `curl -I http://day5.local` returned `200 OK`. `/etc/hosts` is a local mapping on this machine; it does not create a public DNS record.

## 5. Deliberate 502 and recovery

I stopped the Python app while keeping Nginx running. `curl -I http://day5.local` then returned `HTTP/1.1 502 Bad Gateway`.

| Step | Observation |
|---|---|
| Problem | Nginx returned 502 |
| Evidence | Nothing listened on port 3000; direct curl to `127.0.0.1:3000` failed |
| Root cause | The Python upstream had stopped |
| Proxy check | `sudo nginx -t` succeeded |
| Log | Nginx recorded `connect() failed (111: Connection refused) while connecting to upstream` |
| Fix | Restarted the Python server on port 3000 |
| Verification | Port 3000 listened again; `day5.local` returned `200 OK` and `Hello from Day 5 App` |

The observed request path was:

```text
curl → day5.local → /etc/hosts → 127.0.0.1:80
     → Nginx → 127.0.0.1:3000 → Python app → response
```

If the application ran on a separate server, `proxy_pass` would target that server's reachable address, and network routing and firewall rules would need to permit the connection.

## Evidence

The terminal screenshots from this lab show the DNS results, HTTP and TLS inspection, Nginx status, the application and proxy, the 502 log, and the final recovery. The handwritten study pages are shared only with the LinkedIn post.

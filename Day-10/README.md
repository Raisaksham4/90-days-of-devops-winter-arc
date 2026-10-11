# Day 10 - Docker Multi-Stage Builds

This lab compares single-stage, multi-stage, and scratch Docker images for a small Go HTTP service.

## Objectives

- Build a Go application inside Docker.
- Separate the build and runtime stages.
- Reduce the final image size.
- Run the Alpine-based container as a non-root user.
- Verify the HTTP and health endpoints.
- Build and test an optional scratch image.

## Application Endpoints

| Endpoint | Expected response |
|---|---|
| `/` | `Hello from a multi-stage build!` |
| `/health` | `ok` |

## Image Size Comparison

Measured locally using `docker image ls demo`:

| Image | Purpose | Disk usage | Content size |
|---|---|---:|---:|
| `demo:single` | Go toolchain and application | 1.31 GB | 319 MB |
| `demo:build` | Builder stage | 441 MB | 91.3 MB |
| `demo:multi` | Alpine runtime and binary | 19.1 MB | 5.72 MB |
| `demo:scratch` | Static binary only | 6.87 MB | 2.09 MB |

### Multi-Stage Reduction

```text
((319 MB - 5.72 MB) / 319 MB) x 100 = 98.21%
```

The multi-stage image reduced the content size by approximately **98.21%**.

### Scratch Reduction

```text
((319 MB - 2.09 MB) / 319 MB) x 100 = 99.34%
```

The scratch image reduced the content size by approximately **99.34%**.

## Build Commands

```bash
docker build -f Dockerfile.single -t demo:single .
docker build -f Dockerfile -t demo:multi .
docker build --target builder -t demo:build -f Dockerfile .
docker build -f Dockerfile.scratch -t demo:scratch .
docker image ls demo
```

## Run and Validate

```bash
docker run -d --name demo -p 8080:8080 demo:multi

curl http://localhost:8080/
curl http://localhost:8080/health

docker exec demo id
```

Observed runtime identity:

```text
uid=100(app) gid=101(app) groups=101(app)
```

The nonzero UID proves that the Alpine-based runtime container is not running as root.

## Scratch Test

```bash
docker run -d --name demo-scratch -p 8081:8080 demo:scratch

curl http://localhost:8081/
curl http://localhost:8081/health
```

The scratch image contains only the statically compiled Go binary. It has no shell, package manager, or standard debugging utilities.

## Incident-Style Summary

| Item | Finding |
|---|---|
| Problem | The single-stage image was much larger than necessary. |
| Evidence | Its measured content size was 319 MB. |
| Root cause | The final image retained the Go toolchain, source code, and build environment. |
| Fix | The application was compiled in a builder stage and only the binary was copied into the Alpine runtime stage. |
| Verification | The final image was 5.72 MB, both endpoints worked, and `docker exec demo id` showed a non-root user. |

## Security Notes

Running the application as a non-root user limits the actions available to a compromised process. The multi-stage image also reduces the number of packages and build tools present in the runtime environment.

Before production use, I would add automated image scanning, pin base-image digests, add a container health check, and rebuild images regularly for security updates.

## Evidence

- [Image-size comparison](evidence/image-sizes.png)
- [Application, health check, and non-root user](evidence/app-health-and-non-root.png)
- [Builder-stage verification](evidence/builder-target.png)
- [Image inspection and history](evidence/image-inspection.png)
- [Scratch image and health check](evidence/scratch-health.png)

## Cleanup

```bash
docker rm -f demo demo-scratch
```

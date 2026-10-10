# Day 9 - Dockerfile Deep Dive

A small Node.js HTTP API packaged with Docker to practise Dockerfile instructions, runtime configuration, layer caching, CMD, and ENTRYPOINT behavior.

## Project structure

```text
Day-09/
├── Dockerfile
├── Dockerfile.greeter
├── .dockerignore
├── package.json
├── server.js
├── README.md
└── evidence/
```

## Application endpoints

| Endpoint | Expected response |
|---|---|
| `/` | Greeting and current environment |
| `/health` | `ok` |

The server listens on `0.0.0.0` so Docker can publish the container port to the host.

## Dockerfile explanation

```dockerfile
FROM node:20-alpine
```

Uses the lightweight Node.js 20 Alpine Linux base image.

```dockerfile
WORKDIR /app
```

Sets `/app` as the working directory inside the image.

```dockerfile
ARG APP_VERSION=1.0
```

Defines a build time argument. It is available only during image building.

```dockerfile
ENV PORT=3000 \
    APP_ENV=dev \
    APP_VERSION=$APP_VERSION
```

Sets default runtime environment values. `ENV` remains available in the built image and can be overridden at container runtime.

```dockerfile
COPY package*.json ./
RUN npm install --omit=dev
```

Copies stable dependency manifests before application source. This lets Docker reuse the dependency layer when only source code changes.

```dockerfile
COPY . .
```

Copies the application source after dependencies are installed.

```dockerfile
EXPOSE 3000
```

Documents that the application listens on port 3000. It does not publish the port; `docker run -p` does that.

```dockerfile
USER node
```

Runs the application as the non-root `node` user.

```dockerfile
CMD ["node", "server.js"]
```

Provides the default command for the container.

## `.dockerignore`

The build context excludes:

```text
.git
.env
node_modules
*.log
.venv
__pycache__
```

This keeps secrets, local dependencies, logs, and unnecessary files out of the Docker image build context.

## Build and run

Build the image:

```bash
docker build -t day9-api:v1 --build-arg APP_VERSION=1.0 .
```

Run the API:

```bash
docker run -d --name day9-api -p 3000:3000 day9-api:v1
```

Validate it:

```bash
curl http://localhost:3000/
curl http://localhost:3000/health
```

Observed output:

```text
Hello from Docker | env=dev
ok
```

## Runtime configuration

Environment variables can change behavior without rebuilding the image:

```bash
docker rm -f day9-api

docker run -d --name day9-api -p 3000:3000 \
  -e GREETING="Hi Winter Arc" \
  -e APP_ENV=prod \
  day9-api:v1

curl http://localhost:3000/
```

Observed output:

```text
Hi Winter Arc | env=prod
```

An ignored `.env` file also works with `--env-file`:

```bash
docker run -d --name day9-api -p 3000:3000 \
  --env-file .env \
  day9-api:v1
```

## Layer cache experiment

After changing only `server.js`, rebuilding as `day9-api:v2` reused the dependency layer:

```text
Step 6/10 : RUN npm install --omit=dev
 ---> Using cache
```

After changing `package.json`, rebuilding as `day9-api:v3` ran `npm install` again. This shows that dependency changes invalidate the dependency layer, while source only changes do not.

## CMD and ENTRYPOINT

The API image defaults to:

```text
CMD ["node", "server.js"]
```

It can be overridden at runtime:

```bash
docker run --rm day9-api:v3 -e 'console.log("CMD override works")'
```

Observed output:

```text
CMD override works
```

`Dockerfile.greeter` contains:

```dockerfile
FROM alpine:3.20
ENTRYPOINT ["echo", "Hello"]
CMD ["World"]
```

Commands and results:

```bash
docker run --rm day9-greeter:local
# Hello World

docker run --rm day9-greeter:local DevOps
# Hello DevOps
```

`ENTRYPOINT` keeps `echo Hello` as the executable. The runtime argument replaces the default `CMD` value, changing `World` to `DevOps`.

## Image inspection

```bash
docker image inspect day9-api:v3 \
  --format 'User={{.Config.User}} | Cmd={{json .Config.Cmd}} | ExposedPorts={{json .Config.ExposedPorts}}'

docker history day9-api:v3
```

Observed configuration:

```text
User=node | Cmd=["node","server.js"] | ExposedPorts={"3000/tcp":{}}
```

## Production improvements

Before production deployment, I would pin the base image by digest, use `npm ci` with a committed lock file, scan the image for vulnerabilities, pass secrets through a secrets manager, and add a Docker `HEALTHCHECK`.

## Evidence

- `evidence/health-check.png` - root and health endpoint responses
- `evidence/env-override.png` - runtime environment variable override
- `evidence/cache-hit.png` - dependency layer reused after a source only change
- `evidence/cache-miss.png` - dependency layer rebuilt after changing `package.json`
- `evidence/entrypoint-test.png` - ENTRYPOINT and CMD experiment
- `evidence/image-inspection.png` - image metadata, history, and CMD override

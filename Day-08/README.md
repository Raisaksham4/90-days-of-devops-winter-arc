# Day 08 - Docker Fundamentals

## Objective

Learn Docker images, layers, tags, containers, port mapping, image builds, inspection, and port-conflict troubleshooting.

## Docker Engine Check

```bash
docker --version
docker info
```

Docker Engine 29.1.3 was running on Ubuntu WSL.

## Images, Tags, and Layers

```bash
docker run hello-world
docker image ls
docker image history hello-world:latest
docker image inspect hello-world:latest --format '{{json .RepoTags}}'
```

- An image is an immutable package containing the files and configuration needed to run an application.
- `hello-world:latest` uses `hello-world` as the image name and `latest` as its tag.
- `docker image history` showed the image layers, including its `COPY hello /` layer.

## Nginx Test Container

```bash
docker run -d --name day8-nginx -p 8080:80 nginx:alpine
curl -I http://localhost:8080
```

The response returned `HTTP/1.1 200 OK`.

`-p 8080:80` maps port 8080 on the host to port 80 inside the container.

## Custom Web App Image

Created `index.html` and this Dockerfile:

```dockerfile
FROM nginx:alpine
COPY index.html /usr/share/nginx/html/index.html
EXPOSE 80
```

Built the image:

```bash
docker build -t day8-web:1.0 .
docker image history day8-web:1.0
```

Ran the custom image:

```bash
docker run -d --name day8-web -p 8081:80 day8-web:1.0
curl http://localhost:8081
```

The response contained:

```text
DevOps Winter Arc - Day 8
My first Dockerized web app is running!
```

## Port Conflict Troubleshooting

**Problem:** A test container could not start on host port 8081.

**Evidence:**

```text
Bind for 0.0.0.0:8081 failed: port is already allocated
```

**Root Cause:** The `day8-web` container already used host port 8081.

**Fix:** Started a separate container on port 8082:

```bash
docker run -d --name day8-web-8082 -p 8082:80 day8-web:1.0
curl http://localhost:8082
```

**Verification:** The request to `http://localhost:8082` returned the custom Day 8 HTML page.

## Container Inspection

```bash
docker logs day8-web
docker inspect day8-web
docker stats --no-stream day8-web
```

The container was running, Nginx logged a successful `GET /` request, and Docker reported runtime resource usage.

## Key Takeaways

- Images are immutable templates; containers are running instances of images.
- `docker ps` shows running containers, while `docker ps -a` also shows stopped containers.
- `FROM` selects a base image, `COPY` adds application files, and `EXPOSE` documents the intended container port.
- A host port can belong to only one running container at a time.

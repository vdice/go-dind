# go-dind

An [alpine](https://alpinelinux.org/)-based Docker container for doing Go development, equipped with Docker-In-Docker functionality

## dind

To launch the Docker daemon inside this image, run the following:

```console
docker-entrypoint.sh &
```

Processes requiring use of the daemon should now have access.

## misc

This image also currently includes some miscellaneous related tools, such as:

 * kubectl
 * git
 * make
 * golang dev tools (dep, golangci-lint, packr2, goimports)
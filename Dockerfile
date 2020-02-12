FROM lachlanevenson/k8s-kubectl:v1.17.2 as kubectl

FROM golang:1.12.13-alpine3.9 as golang

FROM docker:stable-dind

COPY --from=kubectl /usr/local/bin/kubectl /usr/local/bin/kubectl
COPY --from=golang /usr/local/go /usr/local/go

ENV GOPATH /go
ENV PATH $GOPATH/bin:/usr/local/go/bin:$PATH

ENV DEP_VERSION=v0.5.4
ENV GOLANGCI_LINT_VERSION=v1.21.0
ENV PACKR2_VERSION=v2.7.1
ENV GO_TOOLS_VERSION=release-branch.go1.12

# Add various utilities, both for general usability (bash, make, git)
# as well as golang build-time deps (gcc, musl-dev)
RUN apk add --no-cache bash curl make gcc git musl-dev \
  && curl -sSL \
    -o /usr/local/bin/dep \
    https://github.com/golang/dep/releases/download/$DEP_VERSION/dep-linux-amd64 \
  && chmod 755 /usr/local/bin/dep \
  && curl -sfL \
    https://install.goreleaser.com/github.com/golangci/golangci-lint.sh | sh \
    -s -- -b $GOPATH/bin $GOLANGCI_LINT_VERSION \
  && go get -u github.com/gobuffalo/packr/v2/packr2 \
  && cd $GOPATH/src/github.com/gobuffalo/packr/v2/packr2 \
  && git checkout $PACKR2_VERSION \
  && go install \
  && go get -u golang.org/x/tools/cmd/goimports \
  && cd $GOPATH/src/golang.org/x/tools/cmd/goimports \
  && git checkout $GO_TOOLS_VERSION \
  && go install

WORKDIR $GOPATH
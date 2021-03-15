FROM --platform=${BUILDPLATFORM} golang:alpine3.13 AS build
WORKDIR WORKDIR /go/src/github.com/hkong12/sample-rest-api-golang
ENV CGO_ENABLED=0
COPY . .
ARG TARGETOS
ARG TARGETARCH
RUN GOOS=${TARGETOS} GOARCH=${TARGETARCH} go build -o /out/sample-api .

FROM alpine:3.12 AS bin
COPY --from=build /out/sample-api /bin/
EXPOSE 1323
ENTRYPOINT /bin/sample-api

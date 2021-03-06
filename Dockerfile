FROM golang:alpine3.13 AS build
WORKDIR WORKDIR /go/src/github.com/hkong12/sample-rest-api-golang
ENV CGO_ENABLED=0
COPY . .
ARG TARGETOS
ARG TARGETARCH
RUN GOOS=linux GOARCH=amd64 go build -o /out/sample-api .

FROM alpine:3.12 AS bin
COPY --from=build /out/sample-api /bin/
EXPOSE 80
ENTRYPOINT /bin/sample-api

FROM golang:1.22-alpine AS build
WORKDIR /src
COPY go.mod main.go ./
RUN CGO_ENABLED=0 go build -o /out/app .

FROM alpine:3.20
RUN adduser -D -u 65532 app
USER app
COPY --from=build /out/app /app
ENV PORT=8081
EXPOSE 8081
ENTRYPOINT ["/app"]

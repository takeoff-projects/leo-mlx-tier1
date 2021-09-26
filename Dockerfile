FROM golang:1.17.0-alpine3.13
RUN mkdir /app
ADD . /app
WORKDIR /app
RUN go run main.go
#CMD ["/app/main"]

FROM golang:1.17.0-alpine3.13
ARG GOOGLE_CLOUD_PROJECT=ProjectID_PLACEHOLDER 
RUN mkdir /app
ADD . /app
WORKDIR /app
RUN go build -o main .
CMD ["/app/main"]

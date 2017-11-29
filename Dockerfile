FROM ytnobody/alpine-perl
                                                                                                                             
WORKDIR /app
ADD . /app/
RUN apk update && apk add openssl-dev && rm -fr /var/cache/apk/*
RUN cpm install -g

EXPOSE 25200

ENTRYPOINT plackup -p 25200 

FROM ubuntu:latest

RUN apt update && \
    apt -y install flex bison g++ make

WORKDIR /trabalho4

ENTRYPOINT [ "make", "--quiet" ]

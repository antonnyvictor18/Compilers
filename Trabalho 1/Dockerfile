FROM ubuntu:latest

RUN apt update && \
    apt -y install flex bison g++ make

WORKDIR /trabalho1

ENTRYPOINT [ "make" ]
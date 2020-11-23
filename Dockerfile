FROM postgres:11

RUN apt-get update 
RUN apt-get install --assume-yes --no-install-recommends --no-install-suggests \
  bison \
  build-essential \
  ca-certificates \
  flex \
  git \
  postgresql-server-dev-11 

RUN git clone https://github.com/bitnine-oss/AgensGraph-Extension.git /age 

RUN cd /age && make install 
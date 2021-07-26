FROM alpine:3.13

MAINTAINER Suneel 

USER root
RUN apk update
RUN apk add wget
RUN apk add bash
RUN apk add tar
RUN apk add sudo
RUN apk add net-tools
RUN apk add  unzip
RUN apk add curl
RUN apk add libstdc++ unixodbc unixodbc-dev freetds-dev

WORKDIR /tmp

USER root

RUN apk add --no-cache python3 py3-pip

RUN apk add  nodejs

# update package lists
RUN apk update
# packages to build rubies with RVM in alpine
RUN  apk add postgresql postgresql-contrib


RUN apk add alpine-sdk libtool autoconf automake bison readline-dev \
  zlib-dev yaml-dev gdbm-dev ncurses-dev linux-headers shared-mime-info \
  libffi-dev procps libxml2-dev libxslt-dev gnupg postgresql-dev


SHELL ["/bin/bash", "-l", "-c"]

#RUN gpg --keyserver hkp://pool.sks-keyservers.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 7D2BAF1CF37B13E2069D6956105BD0E739499BDB && \
#    \curl -sSL https://get.rvm.io | bash -s stable

RUN curl -sSL https://rvm.io/mpapis.asc | gpg --import -
RUN curl -sSL https://rvm.io/pkuczynski.asc | gpg --import -

RUN    curl -sSL https://get.rvm.io | bash -s stable


RUN echo 'source "/usr/local/rvm/scripts/rvm"' >> ~/.bashrc


RUN yes ""| rvm install 2.6.5 

RUN yes ""|gem install bundler
RUN yes ""|gem install rails -v 6.1.3.1
RUN rvm use 2.6.5
RUN apk add sqlite-libs sqlite-dev

COPY railsgoat /opt/railsgoat
WORKDIR /opt/railsgoat 
RUN sed -i 's/2.2.2/2.2.3/' Gemfile
RUN /bin/bash -l -c  "gem install shared-mime-info"
RUN /bin/bash -l -c "bundle install"

RUN mkdir -p /run/postgresql/
RUN chmod -R 777 /run/postgresql/
USER postgres
RUN mkdir -p /var/lib/postgresql/data
RUN chmod 0700 /var/lib/postgresql/data &&\
    initdb /var/lib/postgresql/data &&\
    echo "host all  all    0.0.0.0/0  md5" >> /var/lib/postgresql/data/pg_hba.conf &&\
    echo "listen_addresses='*'" >> /var/lib/postgresql/data/postgresql.conf &&\
   /usr/bin/pg_ctl start -D /var/lib/postgresql/data &&\
   psql --command "CREATE USER root WITH SUPERUSER PASSWORD 'root';" &&\
   psql --command "ALTER USER root WITH SUPERUSER;"
 


USER root 

WORKDIR /opt/railsgoat
RUN su - postgres -c "/usr/bin/pg_ctl start -D /var/lib/postgresql/data" &&\
    /bin/bash -l -c "RAILS_ENV=openshift rails db:setup"

EXPOSE 3000
ADD start.sh /
RUN chmod +x /start.sh

CMD ["/start.sh"]

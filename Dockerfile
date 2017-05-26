FROM alpine:3.6

MAINTAINER Alessandro Molari <alessandro.molari@yoroi.company> (alem0lars)

# == BASIC SOFTWARE ============================================================

RUN apk update \
 && apk upgrade

# TODO qui aggiungi i pacchetti di base, ad esempio:
# RUN apk add --update --no-cache gcc libc-dev g++ gfortran make autoconf
# RUN apk add --update --no-cache git bash

# == ENV / PARAMS ==============================================================

# TODO qui setti le variabili e argomenti che ti servono, sicuramente servira'
# l'utente
#
# ENV FOOBAR_USER foobar
# ENV FOOBAR_HOME /home/foobar
#
# ENV DEFAULT_WORKDIR /tmp
# WORKDIR $DEFAULT_WORKDIR

# == USER ======================================================================

RUN adduser -D $FOOBAR_USER -h $FOOBAR_HOME -s /bin/bash

# == DEPENDENCIES ==============================================================

# TODO Qui di solito installo le dipendenze richieste dalla mia applicazione,
# per esempio se richiede altre applicazioni / setup (tipo clonare dei pacchetti
# o roba del genere)...

# == APP =======================================================================

# Install the application as the unpriviliged user.
USER $FOOBAR_USER

# Environment variables (specific for the application).
# TODO:
# ENV APP_DIR /home/foobar/app

# Restore default workdir.
WORKDIR $DEFAULT_WORKDIR
# Change the user back to `root`.
USER root

# == LOGROTATE =================================================================

RUN apk add --update --no-cache logrotate

RUN mv /etc/periodic/daily/logrotate /etc/periodic/hourly/logrotate

# Add glastopf-specific logrotate configuration.
ADD dist/logrotate.conf /etc/logrotate.d/glastopf

# == RSYSLOG ===================================================================

RUN apk add --update --no-cache rsyslog
# TODO cambia con il nome della tua applicazione
ADD dist/rsyslog.conf /etc/rsyslog.d/90-MYAPP.conf

# == SUPERVISORD ===============================================================

RUN apk add --update --no-cache supervisor

ADD dist/supervisord.ini /etc/supervisor.d/supervisord.ini

# == TOOLS (useful when inspecting the container) ==============================

RUN apk add --update --no-cache vim bash-completion

# == ENTRYPOINT ================================================================

CMD ["/usr/bin/supervisord", "-c", "/etc/supervisord.conf"]

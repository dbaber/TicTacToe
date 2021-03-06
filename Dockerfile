FROM alpine:3.8

WORKDIR /

COPY packages.txt /
RUN set -ex && \
    apk update && \
    apk add --no-cache $(cat /packages.txt|grep -v ^#)

RUN set -ex && \
    cpanm Carton

ENV PERL_CARTON_PATH=/local
ENV PERL_CARTON_CPANFILE=/cpanfile

COPY cpanfile cpanfile.snapshot /
RUN set -ex && \
	carton install --deployment --cpanfile=/cpanfile && \
	rm -rf /local/cache && \
	rm -rf /root/.cpanm

COPY bin /opt/tictactoe/bin
COPY environments /opt/tictactoe/environments
COPY lib /opt/tictactoe/lib
COPY public /opt/tictactoe/public
COPY views /opt/tictactoe/views
COPY config.yml /opt/tictactoe/

WORKDIR /opt/tictactoe

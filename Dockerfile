FROM gitlab/gitlab-runner:alpine

MAINTAINER TobiLG <tobilg@gmail.com>

ENV DIND_COMMIT 3b5fac462d21ca164b3778647420016315289034

# Install components and do the preparations
# 1. Install needed package
RUN apk update && apk add dumb-init docker wget device-mapper xz btrfs-progs e2fsprogs e2fsprogs-extra xfsprogs
RUN apk add -U --repository http://dl-cdn.alpinelinux.org/alpine/edge/testing aufs-util

# 2. Install dind
RUN set -x \
	&& addgroup -S dockremap \
	&& adduser -S -G dockremap dockremap \
	&& echo 'dockremap:165536:65536' >> /etc/subuid \
	&& echo 'dockremap:165536:65536' >> /etc/subgid

RUN set -ex; \
	apk add --no-cache --virtual .fetch-deps libressl; \
	wget -O /usr/local/bin/dind "https://raw.githubusercontent.com/docker/docker/${DIND_COMMIT}/hack/dind"; \
	chmod +x /usr/local/bin/dind; \
	apk del .fetch-deps


# 3. Install mesosdns-resolver
RUN wget https://raw.githubusercontent.com/tobilg/mesosdns-resolver/master/mesosdns-resolver.sh -O /usr/local/bin/mesosdns-resolver && \
    chmod +x /usr/local/bin/mesosdns-resolver

# Add wrapper script
ADD register_and_run.sh /

# Expose volumes
VOLUME ["/var/lib/docker", "/etc/gitlab-runner", "/home/gitlab-runner"]

ENTRYPOINT ["/usr/bin/dumb-init", "/register_and_run.sh"]

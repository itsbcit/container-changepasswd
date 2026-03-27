FROM python:3.12-alpine

ARG IMPACKET_VERSION=0.13.0

LABEL maintainer="github.com/ontkanin"
LABEL build_id="1774643296"
LABEL title="changepasswd"
LABEL description="Minimal impacket changepasswd.py for AD password changes"
LABEL version="${IMPACKET_VERSION}"
LABEL source="https://github.com/itsbcit/container-changepasswd"

RUN apk update \
    && apk upgrade \
    && apk cache clean \
    && pip install --no-cache-dir impacket==${IMPACKET_VERSION} \
    && find /usr/local/bin -name "*.py" ! -name "changepasswd.py" -delete \
    && find /usr/local/lib -name "*.pyc" -delete \
    && find /usr/local/lib -name "__pycache__" -type d -exec rm -rf {} + \
    && rm -rf /root/.cache \
    && adduser -D -u 1000 appuser

USER appuser

ENTRYPOINT ["changepasswd.py"]

FROM hashicorp/terraform:1.13.4

COPY . .

RUN apk add --no-cache \
    vault \
    jq && \
    addgroup -S terraform && \
    adduser -S terraform -G terraform && \
    chown -R terraform:terraform /provisioning && \
    chown terraform:terraform docker-entrypoint.sh && \
    chmod +x docker-entrypoint.sh /provisioning/modules/vault/init-vault.sh

USER terraform

ENTRYPOINT [ "docker-entrypoint.sh" ]

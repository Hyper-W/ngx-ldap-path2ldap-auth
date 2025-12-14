FROM busybox:latest AS dir

RUN mkdir -pm 400 /ngx-ldap-path2ldap-auth_conf

FROM alpine:latest AS builder

RUN apk update && apk add --no-cache go git \
    && git clone https://github.com/Hyper-W/ngx_auth_mod.git \
    && cd ngx_auth_mod/src/ngx_auth/exec && cd ngx_ldap_path2ldap_auth/ \
    && CGO_ENABLED=0 go build -ldflags="-s -w" -trimpath -o /usr/bin/ngx_ldap_path2ldap_auth \
    && mkdir -p /ngx-ldap-path2ldap-auth_conf

FROM scratch AS app

COPY --from=dir /ngx-ldap-path2ldap-auth_conf /ngx-ldap-path2ldap-auth_conf
COPY --from=builder /usr/bin/ngx_ldap_path2ldap_auth /ngx_ldap_path2ldap_auth

ENTRYPOINT [ "/ngx_ldap_path2ldap_auth" ]
CMD [ "/ngx-ldap-path2ldap-auth_conf/ngx-ldap-path2ldap-auth.conf" ]
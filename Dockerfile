ARG ModVersionMajor=1
ARG ModVersionMinor=20250220
ARG ModVersionPatch=0
ARG ModVersion="v${ModVersionMajor}.${ModVersionMinor}.${ModVersionPatch}"

FROM alpine:latest AS builder

ARG ModVersion
RUN apk update && apk add --no-cache go git \
    && git clone https://github.com/iij/ngx_auth_mod.git -b ${ModVersion} \
    && cd ngx_auth_mod/src/ngx_auth/exec && cd ngx_ldap_path2ldap_auth/ \
    && CGO_ENABLED=0 go build -ldflags="-s -w" -trimpath -o /usr/bin/ngx_ldap_path2ldap_auth \
    && mkdir -p /ngx-ldap-path2ldap-auth_conf

FROM scratch AS app

COPY --from=builder /usr/bin/ngx_ldap_path2ldap_auth /ngx_ldap_path2ldap_auth
COPY --from=builder /ngx-ldap-path2ldap-auth_conf /ngx-ldap-path2ldap-auth_conf

ENTRYPOINT [ "/ngx_ldap_path2ldap_auth" ]
CMD [ "/ngx-ldap-path2ldap-auth_conf/ngx-ldap-path2ldap-auth.conf" ]
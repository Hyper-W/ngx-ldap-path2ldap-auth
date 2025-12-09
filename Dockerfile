ARG ModVersionMajor=1
ARG ModVersionMinor=20250220
ARG ModVersionPatch=0
ARG ModVersion="v${ModVersionMajor}.${ModVersionMinor}.${ModVersionPatch}"

FROM busybox:latest AS dir

RUN mkdir -pm 400 /ngx-ldap-path2ldap-auth_conf

FROM alpine:latest AS builder

ARG ModVersion
RUN apk update && apk add --no-cache go git \
    && git clone https://github.com/iij/ngx_auth_mod.git -b ${ModVersion} \
    && cd ngx_auth_mod/src/ngx_auth/exec && cd ngx_ldap_path2ldap_auth/ \
    && GOOS=js GOARCH=wasm go build -ldflags="-s -w" -trimpath -o /usr/bin/ngx_ldap_path2ldap_auth.wasm \
    && mkdir -p /ngx-ldap-path2ldap-auth_conf

FROM --platform=wasi/wasm32 scratch AS app

COPY --from=dir /ngx-ldap-path2ldap-auth_conf /ngx-ldap-path2ldap-auth_conf
COPY --from=builder /usr/bin/ngx_ldap_path2ldap_auth.wasm /ngx_ldap_path2ldap_auth.wasm

ENTRYPOINT [ "/ngx_ldap_path2ldap_auth.wasm" ]
CMD [ "/ngx-ldap-path2ldap-auth_conf/ngx-ldap-path2ldap-auth.conf" ]
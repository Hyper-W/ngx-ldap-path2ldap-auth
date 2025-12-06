ARG ModVersionMajor=1
ARG ModVersionMinor=20250220
ARG ModVersionPatch=0
ARG ModVersion="v${ModVersionMajor}.${ModVersionMinor}.${ModVersionPatch}"

FROM --platform=linux/amd64 alpine:latest AS builder

ARG ModVersion
RUN apk update && apk add --no-cache go git \
    && git clone https://github.com/iij/ngx_auth_mod.git -b ${ModVersion} \
    && cd ngx_auth_mod/src/ngx_auth/exec && cd ngx_ldap_path2ldap_auth/ \
    && GOOS=js GOARCH=wasm go build -ldflags="-s -w" -trimpath -o /usr/bin/ngx_ldap_path2ldap_auth.wasm \
    && mkdir -p /ngx-ldap-path2ldap-auth_conf

FROM --platform=wasi/wasm32 scratch AS app

COPY --from=builder /usr/bin/ngx_ldap_path2ldap_auth.wasm /ngx_ldap_path2ldap_auth.wasm
COPY --from=builder /ngx-ldap-path2ldap-auth_conf /ngx-ldap-path2ldap-auth_conf

ENTRYPOINT [ "/ngx_ldap_path2ldap_auth.wasm" ]
CMD [ "/ngx-ldap-path2ldap-auth_conf/ngx-ldap-path2ldap-auth.conf" ]
FROM alpine:3.21

ENV NODE_VERSION=24.4.1
ENV OQS_BRANCH=0.14.0
ENV OQS_PROVIDER_BRANCH=main

# --- Install base packages and dev deps ---
RUN apk add --no-cache \
 curl \
 ca-certificates \
 git \
 bash \
 build-base \
 cmake \
 perl \
 python3 \
 openssl \
 openssl-dev \
 linux-headers \
 libstdc++

# --- Build and install liboqs ---
RUN git clone --branch $OQS_BRANCH https://github.com/open-quantum-safe/liboqs.git \
 && cd liboqs \
 && mkdir build && cd build \
 && cmake -DCMAKE_INSTALL_PREFIX=/usr/local \
 -DBUILD_SHARED_LIBS=ON \
 -DOQS_ENABLE_SIG_DILITHIUM=ON \
 -DOQS_USE_AVX2=OFF .. \
 && make -j$(nproc) && make install \
 && cd ../.. && rm -rf liboqs

# --- Build and install oqs-provider ---
RUN git clone --branch $OQS_PROVIDER_BRANCH https://github.com/open-quantum-safe/oqs-provider.git \
 && cd oqs-provider \
 && mkdir build && cd build \
 && cmake -DCMAKE_INSTALL_PREFIX=/usr/local \
 -DCMAKE_PREFIX_PATH="/usr/local" \
 -DOPENSSL_ROOT_DIR=/usr \
 -DOPENSSL_LIBRARIES=/usr/lib \
 -DOPENSSL_INCLUDE_DIR=/usr/include .. \
 && make -j$(nproc) && make install \
 && cd ../.. && rm -rf oqs-provider

RUN curl -fsSLO "https://nodejs.org/dist/v$NODE_VERSION/node-v$NODE_VERSION.tar.xz" \
 && curl -fsSLO "https://nodejs.org/dist/v$NODE_VERSION/SHASUMS256.txt" \
 && grep " node-v$NODE_VERSION.tar.xz\$" SHASUMS256.txt | sha256sum -c - \
 && tar -xf "node-v$NODE_VERSION.tar.xz" \
 && cd "node-v$NODE_VERSION" \
 && ./configure --fully-static \
 && make -j$(nproc) \
 && make install \
 && cd .. \
 && rm -rf "node-v$NODE_VERSION"*

# --- Clean build deps (keep only runtime) ---
RUN apk del build-base cmake perl python3 linux-headers git curl

# --- Set provider library and runtime paths ---
ENV OPENSSL_MODULES=/usr/lib/ossl-modules
ENV LD_LIBRARY_PATH=/usr/local/lib:/usr/lib:${LD_LIBRARY_PATH}

# --- Patch openssl.cnf to activate oqsprovider and default providers ---
RUN echo "--- Modifying openssl.cnf to enable oqsprovider and default providers ---" \
 # Add oqsprovider_sect section
 && printf "\n[oqsprovider_sect]\nmodule = /usr/lib/ossl-modules/oqsprovider.so\nactivate = 1\n" >> /etc/ssl/openssl.cnf \
 # Enable default provider by uncommenting 'activate = 1' in [default_sect]
 && sed -i '/^\[default_sect\]/,/^$/ s/^# *activate = 1/activate = 1/' /etc/ssl/openssl.cnf \
 # Add oqsprovider entry in [provider_sect]
 && sed -i '/^\[provider_sect\]/a oqsprovider = oqsprovider_sect' /etc/ssl/openssl.cnf \
 && echo "--- openssl.cnf modified ---" \
 && cat /etc/ssl/openssl.cnf

ENV OPENSSL_CONF=/etc/ssl/openssl.cnf
ENV OPENSSL_MODULES=/usr/lib/ossl-modules
ENV LD_LIBRARY_PATH=/usr/local/lib:/usr/lib:${LD_LIBRARY_PATH}

# --- Optional: Smoke tests ---
RUN node --version && npm --version && openssl list -providers | grep oqsprovider

# --- (optional) COPY entrypoint ---
COPY docker-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-entrypoint.sh
ENTRYPOINT ["docker-entrypoint.sh"]

CMD [ "node" ]

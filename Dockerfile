# Build Go programs (only corrupter at the moment)
FROM registry.fedoraproject.org/fedora-minimal:latest AS go-build
RUN microdnf install -y golang git && microdnf clean all
ENV GOPATH=/go
RUN go install github.com/r00tman/corrupter@latest


# Build Python package and dependencies
FROM registry.fedoraproject.org/fedora-minimal:latest AS python-build
RUN microdnf install -y \
        git \
        libffi-devel \
        gcc \
        gcc-c++ \
        leveldb \
        leveldb-devel \
        make \
        zlib-devel \
        libtiff-devel \
        freetype-devel \
        libpng-devel \
        libjpeg-turbo-devel \
        lcms2-devel \
        libwebp-devel \
        openssl-devel \
        cargo \
        python3 \
        python3-devel \
        python3-pip \
    && microdnf clean all
RUN mkdir -p /opt/venv
WORKDIR /opt/venv
RUN python3 -m venv .
ENV PATH="/opt/venv/bin:$PATH"

RUN mkdir -p /src
WORKDIR /src

# Install bot package and dependencies
COPY . .
RUN pip install wheel
RUN pip install plyvel
RUN pip install .[fast]
RUN pip install uvloop


# Package everything
FROM registry.fedoraproject.org/fedora-minimal:latest AS final
# Install optional native tools (for full functionality)
RUN microdnf install -y fastfetch && microdnf clean all
# Install native dependencies
RUN microdnf install -y \
        python3 \
        libffi \
        leveldb \
        zlib \
        libtiff \
        freetype \
        libpng \
        libjpeg-turbo \
        lcms2 \
        libwebp \
    && microdnf clean all

# Create bot user
RUN useradd --system --shell /bin/false pyrobud

# Create data directory for the bot user
RUN mkdir -p /data
RUN chown pyrobud:pyrobud /data

# Copy Go programs
COPY --from=go-build /go/bin/corrupter /usr/local/bin

# Copy Python venv
ENV PATH="/opt/venv/bin:$PATH"
COPY --from=python-build /opt/venv /opt/venv

# Set runtime settings
USER pyrobud
WORKDIR /data
CMD ["pyrobud"]
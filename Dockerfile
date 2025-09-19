# ----------------------------------------------------------
# Dockerfile – SDR++ with NVIDIA OpenGL + external decoders
# ----------------------------------------------------------

FROM nvidia/opengl:1.0-glvnd-runtime-ubuntu22.04

ARG DEBIAN_FRONTEND=noninteractive

# Build + runtime dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
        build-essential \
        cmake \
        git \
        qtbase5-dev \
        qtdeclarative5-dev \
        mesa-utils \
        libgl1 \
        libglx-mesa0 \
        libglx0 \
        libglu1-mesa \
        libxrender1 \
        libxrandr2 \
        libxi6 \
        libudev-dev \
        librtaudio-dev \
        libad9361-dev \
        libusb-1.0-0-dev \
        libhackrf-dev \
        librtlsdr-dev \
        libsoapysdr-dev \
        libairspy-dev \
        libairspyhf-dev \
        libiio-dev \
        libfftw3-dev \
        libpng-dev \
        libsdl2-dev \
        libzstd-dev \
        libglib2.0-dev \
        libglfw3-dev \
        libvolk2-dev \
        pulseaudio-utils \
        alsa-utils \
        libboost-program-options-dev \
        libboost-filesystem-dev \
        libboost-system-dev \
        libproj-dev \
        libgps-dev \
        libcurl4-openssl-dev \
        jq \
        xauth \
        ca-certificates \
    && update-ca-certificates && rm -rf /var/lib/apt/lists/*

# Build Codec2 from source (needed for M17/FreeDV)
RUN git clone --depth 1 https://github.com/drowe67/codec2.git /opt/codec2 && \
    mkdir -p /opt/codec2/build && cd /opt/codec2/build && \
    cmake .. -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/usr && \
    make -j$(nproc) && make install

# Clone SDR++ repo
RUN git clone --depth 1 --recursive https://github.com/AlexandreRouma/SDRPlusPlus.git /opt/sdrpp

# Add radiosonde module into decoder_modules
WORKDIR /opt/sdrpp/decoder_modules
RUN git clone --recurse-submodules https://github.com/dbdexter-dev/sdrpp_radiosonde.git
# Fix radiosonde FM demod init call for new SDR++ API
RUN sed -i 's/fmDemod.init(vfo->output, bw, bw\/2.0f, false);/fmDemod.init(vfo->output, bw, bw\/2.0f, false, false);/' \
    /opt/sdrpp/decoder_modules/sdrpp_radiosonde/src/main.cpp

# Patch SDR++ CMakeLists.txt for radiosonde
WORKDIR /opt/sdrpp
RUN rm -rf build && mkdir build

# Insert option() right after the first "# Decoders" line
RUN sed -i '0,/# Decoders/s//# Decoders\noption(OPT_BUILD_RADIOSONDE_DECODER "Build the radiosonde decoder module (no dependencies required)" ON)\n/' CMakeLists.txt && \
    sed -i '/if (OPT_BUILD_ATV_DECODER)/i if (OPT_BUILD_RADIOSONDE_DECODER)\n  add_subdirectory("decoder_modules/sdrpp_radiosonde")\nendif (OPT_BUILD_RADIOSONDE_DECODER)\n' CMakeLists.txt

# Build SDR++ with radiosonde enabled
WORKDIR /opt/sdrpp/build
RUN cmake .. -DCMAKE_BUILD_TYPE=Release \
      -DCMAKE_INSTALL_PREFIX=/usr \
      -DOPT_BUILD_RADIOSONDE_DECODER=ON \
      -DOPT_BUILD_M17_DECODER=ON \
    && make -j$(nproc) \
    && make install


# --- Startup wrapper ---
RUN cat > /usr/local/bin/start-sdrpp << 'EOF'
#!/bin/bash
set -euo pipefail

CONFIG_FILE="/root/.config/sdrpp/config.json"
mkdir -p /root/.config/sdrpp

if [ ! -f "$CONFIG_FILE" ]; then
  echo "Creating default config.json"
  jq -n --arg r "/usr/share/sdrpp" --arg m "/usr/lib/sdrpp/plugins" \
     '{resourcesDirectory: $r, modulesDirectory: $m}' > "$CONFIG_FILE"
fi

echo "=== Checking install paths ==="
ls -la /usr/share/sdrpp || true
ls -la /usr/lib/sdrpp/plugins || true

echo "=== SDR++ Plugins Found ==="
ls -la /usr/lib/sdrpp/plugins/*.so || true

echo "=== Starting SDR++ ==="
exec sdrpp
EOF

RUN chmod +x /usr/local/bin/start-sdrpp

CMD ["/usr/local/bin/start-sdrpp"]

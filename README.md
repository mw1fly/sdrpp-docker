# SDR++ Docker Environment with Plugins

This repository contains a Docker build setup for [SDR++](https://github.com/AlexandreRouma/SDRPlusPlus) with additional decoder plugins, including **radiosonde**.  
The goal is to provide a clean, reproducible environment with GPU acceleration and persistent config support.

---

## 📦 Included Components
- **Base image**: `nvidia/opengl:1.0-glvnd-runtime-ubuntu22.04`
- **SDR++** (cloned and built from source)
- **Codec2** (built from source, required by some decoders like M17 / FreeDV)
- **Radiosonde decoder** (integrated into SDR++ via CMake)
- **M17 decoder** (optional, enabled by build flag)

---

## 🚀 Building

Clone this repo and build the container:

```bash
git clone https://github.com/<your-username>/sdrpp-docker.git
cd sdrpp-docker
docker build -t sdrpp .


---

## ▶️ Running

Run with GPU access (adjust depending on your system)

```bash
docker run -it --rm \
  --device /dev/snd \
  --device /dev/bus/usb \
  -e DISPLAY=$DISPLAY \
  -v /tmp/.X11-unix:/tmp/.X11-unix \
  sdrpp

---

This will start sdrpp inside the container with X11 forwarding.
Your SDR++ config files are stored in /root/.config/sdrpp inside the container.
If you want persistent configs, mount a volume:

```bash
docker run -it --rm \
  -v $HOME/.config/sdrpp:/root/.config/sdrpp \
  sdrpp

---

## 🔧 Plugin Management

Radiosonde

Added via decoder_modules/sdrpp_radiosonde

Enabled with:

```bash
-DOPT_BUILD_RADIOSONDE_DECODER=ON

---

M17 Decoder

Enabled with:

```bash
-DOPT_BUILD_M17_DECODER=ON

---

FreeDV / DSD

Not included by default because they require authenticated repos.

To add, clone into external_modules/ and patch CMakeLists.txt.

---

## 🛠 Development Notes

.gitignore excludes all cloned upstream sources (/opt/sdrpp, /opt/codec2) and build outputs.

To add new plugins:

Clone into external_modules/

Add the appropriate option(...) and add_subdirectory(...) lines in SDR++’s CMakeLists.txt

Rebuild with docker build --no-cache -t sdrpp .

---

## 📌 TODO

Add docker-compose.yml for easier runtime options

Add persistent audio device mapping examples

Automate additional plugin inclusion


```bash

---

## ⚡ This README gives you:  
- A quick overview of what’s inside.  
- Build + run instructions.  
- Notes on plugin handling.  

Would you like me to also **add badges and version tags** (like GitHub Actions CI/CD for builds, or Docker Hub push if you plan to publish)?

---

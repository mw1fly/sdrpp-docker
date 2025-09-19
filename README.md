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

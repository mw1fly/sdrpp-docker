docker run -it --rm --gpus all \
  -e DISPLAY=$DISPLAY \
  -v /tmp/.X11-unix:/tmp/.X11-unix \
  -v $HOME/.Xauthority:/root/.Xauthority:ro \
  -v $XDG_RUNTIME_DIR/pulse/native:/tmp/pulse/native \
  -e PULSE_SERVER=unix:/tmp/pulse/native \
  --device /dev/bus/usb:/dev/bus/usb \
  --group-add audio \
  -v $HOME/apps/sdrpp-docker/config:/root/.config/sdrpp \
  -v $HOME/apps/sdrpp-docker/recordings:/root/.local/share/sdrpp/recordings \
  sdrpp

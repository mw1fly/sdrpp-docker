#! /bin/bash
# Drop to bash prompt.

docker run -it --rm --gpus all   -e DISPLAY=$DISPLAY   -v /tmp/.X11-unix:/tmp/.X11-unix   -v $HOME/.Xauthority:/root/.Xauthority:ro   sdrpp bash



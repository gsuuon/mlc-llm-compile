#!/bin/bash

if [ -z "$WEIGHTS_REPO_URL" ]; then
  echo "Error: WEIGHTS_REPO_URL is not set";
  exit 1;
fi

source /root/.bashrc;

git clone $WEIGHTS_REPO_URL ./weights;
mlc_llm compile ./weights/mlc-chat-config.json --device webgpu -o out/out.wasm;

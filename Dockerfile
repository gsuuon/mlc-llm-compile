FROM python:3.11-bookworm

RUN apt-get update

RUN apt-get install -y cmake
RUN apt-get install git-lfs; git lfs install

RUN curl https://sh.rustup.rs -sSf | sh -s -- -y
ENV PATH="/root/.cargo/bin:${PATH}"

RUN git clone --recursive https://github.com/mlc-ai/mlc-llm.git

ENV TVM_HOME=/mlc-llm/3rdparty/tvm

RUN mkdir mlc-llm/build

WORKDIR mlc-llm/build
RUN python ../cmake/gen_cmake_config.py <<EOF
/mlc-llm/3rdparty/tvm
n
n
n
n
n
n
n
n
n
EOF
RUN cmake .. 
RUN cmake --build . --parallel 16
RUN cd /mlc-llm/python; pip install -e .
RUN python -m pip install --pre -U -f https://mlc.ai/wheels mlc-ai-nightly

WORKDIR /
RUN git clone https://github.com/emscripten-core/emsdk.git
RUN /emsdk/emsdk install latest
RUN /emsdk/emsdk activate latest
RUN echo "source /emsdk/emsdk_env.sh" >> /root/.bashrc
ENV EMSDK_QUIET=1
ENV MLC_LLM_HOME=/mlc-llm

RUN bash -c "source /emsdk/emsdk_env.sh; cd /mlc-llm; ./web/prep_emcc_deps.sh"

RUN mkdir out

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT [ "/entrypoint.sh" ]

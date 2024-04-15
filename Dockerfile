FROM ubuntu:22.04

RUN apt-get update 
RUN apt-get install -y protobuf-compiler libprotobuf-dev binutils cmake \
    ninja-build liblzma-dev libz-dev pkg-config autoconf libtool git

RUN apt-get install -y libfuzzer-14-dev lld-14 llvm-14 llvm-14-dev clang-14
RUN apt-get install -y gcc-$(gcc --version|head -n1|sed 's/\..*//'|sed 's/.* //')-plugin-dev \
    libstdc++-$(gcc --version|head -n1|sed 's/\..*//'|sed 's/.* //')-dev

WORKDIR /root
RUN git clone https://github.com/google/libprotobuf-mutator.git libprotobuf-mutator
WORKDIR /root/libprotobuf-mutator
RUN git reset --hard af3bb1
RUN mkdir build
WORKDIR /root/libprotobuf-mutator/build

RUN cmake .. -GNinja -DCMAKE_C_COMPILER=clang-14 \ 
    -DCMAKE_CXX_COMPILER=clang++-14 \ 
    -DCMAKE_BUILD_TYPE=Debug \ 
    -DLIB_PROTO_MUTATOR_DOWNLOAD_PROTOBUF=ON \ 
    -DBUILD_SHARED_LIBS=ON
RUN cmake .. -GNinja -DCMAKE_C_COMPILER=clang-14 \
    -DCMAKE_CXX_COMPILER=clang++-14 \
    -DCMAKE_BUILD_TYPE=Debug \
    -DLIB_PROTO_MUTATOR_DOWNLOAD_PROTOBUF=ON \
    -DCMAKE_C_FLAGS="-fPIC" -DCMAKE_CXX_FLAGS="-fPIC"
RUN ninja 
RUN ninja install

WORKDIR /root
RUN git clone https://github.com/AFLplusplus/AFLplusplus.git aflplusplus 
WORKDIR /root/aflplusplus
RUN git reset --hard 61e27c
RUN make all && make install

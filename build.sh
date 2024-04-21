echo "Building MacMind"
cd "tooling"

echo "Fetching Retro68"
if [ ! -d "Retro68" ]; then
    git clone --depth 1 https://github.com/autc04/Retro68.git 
fi

echo "Updating Retro68"
cd Retro68
git pull

echo "Copying source code"
rm -rf MacMind
mkdir MacMind
cp -r ../../src/* MacMind

echo "Building MacMind"
docker run --rm -v $(pwd):/root -i ghcr.io/autc04/retro68 /bin/bash <<"EOF"
    cd MacMind
    rm -rf build && mkdir build && cd build
    cmake .. -DCMAKE_TOOLCHAIN_FILE=/Retro68-build/toolchain/m68k-apple-macos/cmake/retro68.toolchain.cmake
    make
EOF

echo "Copying distribution files"
cp MacMind/build/* ../dist

echo "Cleaning up"
rm -rf MacMind

echo "🎉 Done 🎉"

cd "tooling"

echo "Fetching Retro68"
if [ ! -d "Retro68" ]; then
    git clone --depth 1 https://github.com/autc04/Retro68.git 
fi

echo "Fetching tty0tty"
if [ ! -d "tty0tty" ]; then
    git clone git@github.com:freemed/tty0tty.git
fi

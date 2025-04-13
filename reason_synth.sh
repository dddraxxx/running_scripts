git clone git@github.com:dddraxxx/reason-synth.git
cd reason-synth
bash uv_pip.sh
# Initialize and update submodules
git pull && git submodule update --init --recursive
cd easyr1 && git pull origin main && git checkout main

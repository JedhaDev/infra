sudo apt-get --assume-yes update
sudo apt --assume-yes install software-properties-common
sudo add-apt-repository -y ppa:deadsnakes/ppa

sudo apt --assume-yes install python3.9

sudo apt --assume-yes install python3-pip

sudo apt-get --assume-yes install python3-virtualenv

sudo apt --assume-yes update
sudo apt --assume-yes install build-essential zlib1g-dev libncurses5-dev libgdbm-dev libnss3-dev libssl-dev libreadline-dev libffi-dev libsqlite3-dev wget libbz2-dev

wget -q https://raw.githubusercontent.com/AUTOMATIC1111/stable-diffusion-webui/master/webui.sh

# Conda
wget https://repo.continuum.io/archive/Anaconda3-4.2.0-Linux-x86_64.sh
sudo bash Anaconda3-4.2.0-Linux-x86_64.sh -b -p ~/anaconda

PATH="$HOME/anaconda/bin:$PATH"
source .bashrc

conda update conda

# Clone the SD WebUI
git clone https://github.com/AUTOMATIC1111/stable-diffusion-webui.git

# Go to the models folder
cd stable-diffusion-webui/models/Stable-diffusion/

# Download Stable Diffusion 1.5 checkpoint (requires a HuggingFace auth token)
curl -H "Authorization: Bearer <your-huggingface-token>" https://huggingface.co/runwayml/stable-diffusion-v1-5/resolve/main/v1-5-pruned-emaonly.ckpt --location --output v1-5-pruned-emaonly.ckpt

# Create a new Conda env with the desired Python version
sudo conda create -n a1111-sdwebui python=3.10 -y

# Activate the new env
sudo conda source activate a1111-sdwebui

# Go back to the root of the repo..
cd ../..

sudo pip install --upgrade pip

# ..so we can install the repository's dependencies..
sudo pip install -r GitPython
sudo pip install -r Pillow
sudo pip install -r accelerate

sudo pip install -r basicsr
sudo pip install -r blendmodes
sudo pip install -r clean-fid
sudo pip install -r einops
sudo pip install -r gfpgan
sudo pip install -r gradio==3.32.0
sudo pip install -r inflection
sudo pip install -r jsonmerge
sudo pip install -r kornia
sudo pip install -r lark
sudo pip install -r numpy
sudo pip install -r omegaconf

sudo pip install -r piexif
sudo pip install -r psutil
sudo pip install -r pytorch_lightning
sudo pip install -r realesrgan
sudo pip install -r requests
sudo pip install -r resize-right

sudo pip install -r safetensors
sudo pip install -r scikit-image>=0.19
sudo pip install -r timm
sudo pip install -r tomesd
sudo pip install -r torch
sudo pip install -r torchdiffeq
sudo pip install -r torchsde
sudo pip install -r transformers==4.25.1

sudo apt-get update
sudo apt-get upgrade -y
sudo apt-get dist-upgrade -y
sudo apt-get install cuda-drivers

# ..which for some reason won't install everything leading to the web ui crashing 
# while complaining about `undefined symbol: cublasLtGetStatusString, version libcublasLt.so.11`
# So, we need to install the missing dependencies directly from conda
sudo conda install pytorch=1.13 torchvision=0.14 torchaudio=0.13 pytorch-cuda=11.7 -c pytorch -c nvidia -y


# If you want/need an older version, see the alternatives here https://pytorch.org/get-started/previous-versions/
# e.g. I've had success with 
# conda install pytorch==1.12.1 torchvision==0.13.1 torchaudio==0.12.1 cudatoolkit=11.3 -c pytorch -y

# Mark everything as a safe directory,
# we need this because when first run,
# the web ui will try to clone some repos under this directory, 
# and we'll get a lot of dubious ownership errors,
# which we don't really want to be honest
git config --global --add safe.directory '*'

# Don't forget to pick a good userame/password combo, otherwise anyone will be able to access your instance
sudo accelerate launch --mixed_precision=bf16 --num_cpu_threads_per_process=6 launch.py --share --gradio-auth $1:$2


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
wget https://repo.anaconda.com/archive/Anaconda3-2022.05-Linux-x86_64.sh 
sudo bash Anaconda3-2022.05-Linux-x86_64.sh  -b -p /anaconda

PATH="/anaconda/bin:$PATH"
source .bashrc

sudo /anaconda/bin/conda update conda -y

# sudo add-apt-repository ppa:graphics-drivers/ppa 
# sudo apt update 
# sudo apt install nvidia-driver-460 # replace 460 with your specific version

sudo apt-get --assume-yes update
sudo apt-get upgrade -y
# sudo apt-get dist-upgrade -y
sudo apt install nvidia-driver-460 # replace 460 with your specific version
sudo apt-get install cuda-drivers


# Clone the SD WebUI
git clone https://github.com/AUTOMATIC1111/stable-diffusion-webui.git

# Go to the models folder
cd stable-diffusion-webui/models/Stable-diffusion/

wget https://civitai.com/api/download/models/114367 -O realisticVisionV40_v40VAE.safetensors

# Download Stable Diffusion 1.5 checkpoint (requires a HuggingFace auth token)
# curl -H "Authorization: Bearer <your-huggingface-token>" https://huggingface.co/runwayml/stable-diffusion-v1-5/resolve/main/v1-5-pruned-emaonly.ckpt --location --output v1-5-pruned-emaonly.ckpt

# Create a new Conda env with the desired Python version
sudo /anaconda/bin/conda create -n a1111-sdwebui python=3.10 -y

# Activate the new env
sudo /anaconda/bin/conda activate a1111-sdwebui

# Go back to the root of the repo..
cd ../..

sudo pip install --upgrade pip

# ..so we can install the repository's dependencies..
sudo pip install --root-user-action=ignore GitPython
sudo pip install --root-user-action=ignore Pillow
sudo pip install --root-user-action=ignore accelerate

sudo pip install --root-user-action=ignore basicsr
sudo pip install --root-user-action=ignore blendmodes
sudo pip install --root-user-action=ignore clean-fid
sudo pip install --root-user-action=ignore einops
sudo pip install --root-user-action=ignore gfpgan
sudo pip install --root-user-action=ignore gradio==3.32.0
sudo pip install --root-user-action=ignore inflection
sudo pip install --root-user-action=ignore jsonmerge
sudo pip install --root-user-action=ignore kornia
sudo pip install --root-user-action=ignore lark
sudo pip install --root-user-action=ignore numpy
sudo pip install --root-user-action=ignore omegaconf

sudo pip install --root-user-action=ignore piexif
sudo pip install --root-user-action=ignore psutil
sudo pip install --root-user-action=ignore pytorch_lightning
sudo pip install --root-user-action=ignore realesrgan
sudo pip install --root-user-action=ignore requests
sudo pip install --root-user-action=ignore resize-right

sudo pip install --root-user-action=ignore safetensors
sudo pip install --root-user-action=ignore scikit-image>=0.19
sudo pip install --root-user-action=ignore timm
sudo pip install --root-user-action=ignore tomesd
sudo pip install --root-user-action=ignore torch
sudo pip install --root-user-action=ignore torchdiffeq
sudo pip install --root-user-action=ignore torchsde
sudo pip install --root-user-action=ignore transformers==4.25.1
sudo pip install --root-user-action=ignore chardet

# ..which for some reason won't install everything leading to the web ui crashing 
# while complaining about `undefined symbol: cublasLtGetStatusString, version libcublasLt.so.11`
# So, we need to install the missing dependencies directly from conda
sudo /anaconda/bin/conda install pytorch==2.0.0 torchvision==0.15.0 torchaudio==2.0.0 pytorch-cuda=11.8 -c pytorch -c nvidia

# Mark everything as a safe directory,
# we need this because when first run,
# the web ui will try to clone some repos under this directory, 
# and we'll get a lot of dubious ownership errors,
# which we don't really want to be honest
git config --global --add safe.directory '*'

# Don't forget to pick a good userame/password combo, otherwise anyone will be able to access your instance
sudo accelerate launch --mixed_precision=bf16 --num_cpu_threads_per_process=6 launch.py --share --gradio-auth $1:$2

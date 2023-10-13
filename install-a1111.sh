sudo apt-get --assume-yes update
sudo add-apt-repository -y ppa:deadsnakes/ppa
sudo apt-get --assume-yes update

sudo apt --assume-yes install software-properties-common build-essential zlib1g-dev libncurses5-dev libgdbm-dev libnss3-dev libssl-dev libreadline-dev libffi-dev libsqlite3-dev wget libbz2-dev
sudo apt --assume-yes install python3.9 python3-pip python3-virtualenv

#sudo apt-get upgrade -y

wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2004/x86_64/cuda-keyring_1.0-1_all.deb 
sudo dpkg -i cuda-keyring_1.0-1_all.deb
sudo apt-get --assume-yes  update
sudo apt-get -y install cuda-drivers

wget -q https://raw.githubusercontent.com/AUTOMATIC1111/stable-diffusion-webui/master/webui.sh

# Conda
wget https://repo.anaconda.com/archive/Anaconda3-2022.05-Linux-x86_64.sh 
sudo bash Anaconda3-2022.05-Linux-x86_64.sh  -b -p /anaconda

PATH="/anaconda/bin:$PATH"
source .bashrc

sudo /anaconda/bin/conda update conda -y

sudo pip install --upgrade pip

apt install python3.10-venv

# ..so we can install the repository's dependencies..
pip install GitPython
pip install Pillow
pip install accelerate

pip install basicsr
pip install blendmodes
pip install clean-fid
pip install einops
pip install gfpgan
pip install gradio==3.32.0
pip install inflection
pip install jsonmerge
pip install kornia
pip install lark
pip install numpy
pip install omegaconf

pip install piexif
pip install psutil
pip install pytorch_lightning
pip install realesrgan
pip install requests
pip install resize-right

pip install safetensors
pip install scikit-image>=0.19
pip install timm
pip install tomesd
pip install torch
pip install torchdiffeq
pip install torchsde
pip install transformers==4.25.1
pip install chardet


# Clone the SD WebUI
git clone https://github.com/AUTOMATIC1111/stable-diffusion-webui.git

# Go to the models folder
cd stable-diffusion-webui/models/Stable-diffusion/

wget https://civitai.com/api/download/models/114367 -O realisticVisionV40_v40VAE.safetensors

# Download Stable Diffusion 1.5 checkpoint (requires a HuggingFace auth token)
# curl -H "Authorization: Bearer <your-huggingface-token>" https://huggingface.co/runwayml/stable-diffusion-v1-5/resolve/main/v1-5-pruned-emaonly.ckpt --location --output v1-5-pruned-emaonly.ckpt

# Create a new Conda env with the desired Python version
/anaconda/bin/conda create -n a1111-sdwebui python=3.10 -y

# Activate the new env
/anaconda/bin/conda activate a1111-sdwebui

# Go back to the root of the repo..
cd ../..


# ..which for some reason won't install everything leading to the web ui crashing 
# while complaining about `undefined symbol: cublasLtGetStatusString, version libcublasLt.so.11`
# So, we need to install the missing dependencies directly from conda
/anaconda/bin/conda install pytorch==2.0.0 torchvision==0.15.0 torchaudio==2.0.0 pytorch-cuda=11.8 -c pytorch -c nvidia

# Mark everything as a safe directory,
# we need this because when first run,
# the web ui will try to clone some repos under this directory, 
# and we'll get a lot of dubious ownership errors,
# which we don't really want to be honest
git config --global --add safe.directory '*'

# Don't forget to pick a good userame/password combo, otherwise anyone will be able to access your instance
# sudo accelerate launch --mixed_precision=bf16 --num_cpu_threads_per_process=6 launch.py --share --gradio-auth $1:$2

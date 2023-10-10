apt-get update

# Debian-based:
sudo apt install wget git python3 python3-venv libgl1 libglib2.0-0
# Red Hat-based:
sudo dnf install wget git python3
# Arch-based:
sudo pacman -S wget git python3

sudo apt --assume-yes install python3-pip

sudo apt-get --assume-yes install python3-virtualenv

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

sudo pip install accelerate

# ..so we can install the repository's dependencies..
sudo pip install -r requirements_versions.txt 

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


sudo apt-get --assume-yes update
sudo add-apt-repository -y ppa:deadsnakes/ppa
sudo apt-get --assume-yes update

sudo apt --assume-yes install software-properties-common build-essential zlib1g-dev libncurses5-dev libgdbm-dev libnss3-dev libssl-dev libreadline-dev libffi-dev libsqlite3-dev wget libbz2-dev
sudo apt --assume-yes install python3.9 python3-pip python3-virtualenv

wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2004/x86_64/cuda-keyring_1.0-1_all.deb 
sudo dpkg -i cuda-keyring_1.0-1_all.deb
sudo apt-get --assume-yes  update
sudo apt-get -y install cuda-drivers

# Conda
wget https://repo.anaconda.com/archive/Anaconda3-2022.05-Linux-x86_64.sh 
sudo bash Anaconda3-2022.05-Linux-x86_64.sh  -b -p /anaconda

PATH="/anaconda/bin:$PATH"
source .bashrc

sudo /anaconda/bin/conda update conda -y

#sudo pip install --upgrade pip
apt --assume-yes install python3.10-venv

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

# Create a new Conda env with the desired Python version
/anaconda/bin/conda create -n a1111-sdwebui python=3.10 -y

# Activate the new env
# /anaconda/bin/conda activate a1111-sdwebui

# Go back to the root of the repo..
cd /home/dev
/anaconda/bin/conda install pytorch==2.0.0 torchvision==0.15.0 torchaudio==2.0.0 pytorch-cuda=11.8 -c pytorch -c nvidia

################################### INSTANCE 1 - Academy
cd /home/dev
mkdir instance1
cd /home/dev/instance1
mkdir blobtemp
# Clone the SD WebUI
git clone https://github.com/AUTOMATIC1111/stable-diffusion-webui.git
cd stable-diffusion-webui
mkdir outputs
cd extensions
git clone https://github.com/d8ahazard/sd_dreambooth_extension.git

cd ../models/Stable-diffusion/
wget https://civitai.com/api/download/models/114367 -O realisticVisionV40_v40VAE.safetensors

################################### INSTANCE 2 - Shooter
cd /home/dev
mkdir instance2
cd /home/dev/instance2
mkdir blobtemp
# Clone the SD WebUI
git clone https://github.com/AUTOMATIC1111/stable-diffusion-webui.git
cd stable-diffusion-webui
mkdir outputs
cd extensions
git clone https://github.com/kex0/batch-face-swap.git
git clone https://github.com/Mikubill/sd-webui-controlnet.git

cd ../models/Stable-diffusion/
wget https://civitai.com/api/download/models/114367 -O realisticVisionV40_v40VAE.safetensors

################################### Mounting Azure Storage
cd /home/dev

wget https://packages.microsoft.com/config/ubuntu/20.04/packages-microsoft-prod.deb
sudo dpkg -i packages-microsoft-prod.deb
sudo apt-get --assume-yes  update
sudo apt-get  --assume-yes install blobfuse fuse

echo "# ----- Adding azure storage account" | sudo tee -a /etc/profile
echo "export AZURE_STORAGE_ACCOUNT=$1" | sudo tee -a /etc/profile
echo "export AZURE_STORAGE_ACCESS_KEY=$2" | sudo tee -a /etc/profile

cd /home/dev
echo "# ----- Adding azure storage account" | sudo tee -a mount.sh
echo "export AZURE_STORAGE_ACCOUNT=$1" | sudo tee -a mount.sh
echo "export AZURE_STORAGE_ACCESS_KEY=$2" | sudo tee -a mount.sh
echo "sudo -H -u dev blobfuse /home/dev/instance1/stable-diffusion-webui/outputs --tmp-path=/home/dev/instance1/blobtemp -o attr_timeout=240 -o entry_timeout=240 -o negative_timeout=120 --container-name=shooter --log-level=LOG_DEBUG --file-cache-timeout-in-seconds=120" | sudo tee -a mount.sh
echo "sudo -H -u dev blobfuse /home/dev/instance2/stable-diffusion-webui/outputs --tmp-path=/home/dev/instance2/blobtemp -o attr_timeout=240 -o entry_timeout=240 -o negative_timeout=120 --container-name=academy --log-level=LOG_DEBUG --file-cache-timeout-in-seconds=120" | sudo tee -a mount.sh



################################### Adding autostart
cd /home/dev
wget https://raw.githubusercontent.com/JedhaDev/infra/main/start.data
mv start.data rc.local
sudo chmod +x rc.local
sudo cp rc.local /etc/rc.local


################################### Adding AZURE FUNCTIONS
cd /home/dev
sudo chown -R dev *

#mkdir functions
#cd functions
#git clone https://$3:$4@raonadev.visualstudio.com/HereWeGo/_git/neural.functions.Academy
#cd neural.functions.Academy
#git checkout dev

#cd /home/dev/functions
#git clone https://$3:$4@raonadev.visualstudio.com/HereWeGo/_git/neural.functions.Shooter
#cd neural.functions.Shooter
#git checkout dev

#cd /home/dev
#sudo apt-get update
#sudo apt-get install -y dotnet-sdk-6.0

#curl https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > microsoft.gpg
#sudo mv microsoft.gpg /etc/apt/trusted.gpg.d/microsoft.gpg

#sudo sh -c 'echo "deb [arch=amd64] https://packages.microsoft.com/repos/microsoft-ubuntu-$(lsb_release -cs)-prod $(lsb_release -cs) main" > /etc/apt/sources.list.d/dotnetdev.list'
#sudo apt-get update
#sudo apt-get install azure-functions-core-tools-4

#cd /home/dev/functions/neural.functions.Academy/AcademiaFunctionApp
#echo cd /home/dev/functions/neural.functions.Academy/AcademiaFunctionApp >> start.sh
#echo func start --port 7072 >> start.sh
#sudo chmod +x start.sh
#./start.sh &

#cd /home/dev/functions/neural.functions.Shooter
#echo cd /home/dev/functions/neural.functions.Shooter >> start.sh 
#echo func start >> start.sh
#sudo chmod +x start.sh
#./start.sh &


## pending download and install net6
## pending to pass ENV variables to support azure functions
## pending create job to automatic start functions

#./webui.sh --share --enable-insecure-extension-access &

#start on startup
#task
#exec /home/dev/stable-diffusion-webui/webui.sh --share --enable-insecure-extension-access &

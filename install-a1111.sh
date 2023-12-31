sudo apt-get --assume-yes update
sudo add-apt-repository -y ppa:deadsnakes/ppa
sudo apt-get --assume-yes update

sudo apt --assume-yes install software-properties-common build-essential zlib1g-dev libncurses5-dev libgdbm-dev libnss3-dev libssl-dev libreadline-dev libffi-dev libsqlite3-dev wget libbz2-dev
sudo apt --assume-yes install python3.9 python3-pip python3-virtualenv

#sudo apt --assume-yes install git build-essential
#sudo apt --assume-yes install python3-pip python3-venv python3-dev
# fix <cmath> not found
#sudo apt --assume-yes install libstdc++-12-dev
# optional, suppress warnings from torchvision
#sudo apt --assume-yes install libpng-dev libjpeg-dev

################################### CUDA
wget https://raw.githubusercontent.com/TimDettmers/bitsandbytes/main/cuda_install.sh
sudo chmod +x cuda_install.sh
bash cuda_install.sh 113 ~/local/

wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2004/x86_64/cuda-keyring_1.0-1_all.deb 
sudo dpkg -i cuda-keyring_1.0-1_all.deb

sudo apt-get --assume-yes  update
sudo apt-get -y install cuda-drivers

#sudo apt --assume-yes  autoremove nvidia* --purge
#sudo apt --assume-yes install nvidia-driver-525
#sudo apt --assume-yes install nvidia-cuda-toolkit

sudo apt update
sudo apt install python3-venv -y
sudo apt install unzip -y
mkdir pytorch_env
cd pytorch_env
python3 -m venv pytorch_env
source pytorch_env/bin/activate

#pip3 install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cpu
#pip3 install torch torchvision torchaudio

# Conda
wget https://repo.anaconda.com/archive/Anaconda3-2022.05-Linux-x86_64.sh 
sudo bash Anaconda3-2022.05-Linux-x86_64.sh  -b -p /anaconda

PATH="/anaconda/bin:$PATH"
source .bashrc

sudo /anaconda/bin/conda update conda -y

#sudo pip install --upgrade pip
#apt install --assume-yes python3.10-venv
sudo apt-get --assume-yes install fuse3

# Create a new Conda env with the desired Python version
/anaconda/bin/conda create -n a1111-sdwebui python=3.10 -y

# Activate the new env
# /anaconda/bin/conda activate a1111-sdwebui

# Go back to the root of the repo..
cd /home/dev
#/anaconda/bin/conda install pytorch==2.0.0 torchvision==0.15.0 torchaudio==2.0.0 pytorch-cuda=11.8 -c pytorch -c nvidia

#pip install -U diffusers accelerate transformers
#pip install -U discord_webhook
#pip install diffusers

################################### INSTANCE 1 - Shooter
cd /home/dev
mkdir instance1
cd /home/dev/instance1
mkdir blobtemp
# Clone the SD WebUI
git clone https://github.com/AUTOMATIC1111/stable-diffusion-webui.git
cd stable-diffusion-webui
python3 -m venv venv
source venv/bin/activate
pip3 install -r requirements.txt
pip3 uninstall --yes torch torchvision
pip3 install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/rocm5.6
mkdir outputs
cd extensions
git clone https://github.com/kex0/batch-face-swap.git
#git clone https://github.com/glucauze/sd-webui-faceswaplab.git
git clone https://github.com/Mikubill/sd-webui-controlnet.git
git clone https://github.com/facebookresearch/xformers.git

cd /home/dev/instance1/stable-diffusion-webui/models/Stable-diffusion/
wget https://civitai.com/api/download/models/114367 -O realisticVisionV40_v40VAE.safetensors

################################### INSTANCE 2 - Academy
cd /home/dev
mkdir instance2
cd /home/dev/instance2
mkdir blobtemp
# Clone the SD WebUI
git clone https://github.com/AUTOMATIC1111/stable-diffusion-webui.git
cd stable-diffusion-webui
python3 -m venv venv
source venv/bin/activate
pip3 install -r requirements.txt
#pip3 uninstall --yes torch torchvision
#pip3 install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/rocm5.6
mkdir outputs
cd extensions
#git clone https://github.com/d8ahazard/sd_dreambooth_extension.git
wget https://github.com/d8ahazard/sd_dreambooth_extension/archive/refs/tags/1.0.14.zip
unzip 1.0.14.zip 
rm 1.0.14.zip
git clone https://github.com/facebookresearch/xformers.git

cd /home/dev/instance2/stable-diffusion-webui/models/Stable-diffusion/
wget https://civitai.com/api/download/models/114367 -O realisticVisionV40_v40VAE.safetensors

################################### Mounting Azure Storage
cd /home/dev

wget https://packages.microsoft.com/config/ubuntu/20.04/packages-microsoft-prod.deb
sudo dpkg -i packages-microsoft-prod.deb
sudo apt-get --assume-yes  update
sudo apt-get  --assume-yes install blobfuse fuse

cd /home/dev
echo "# ----- Configuration storage" | sudo tee -a conn-shooter.cfg
echo "accountName $1" | sudo tee -a conn-shooter.cfg
echo "accountKey $2" | sudo tee -a conn-shooter.cfg
echo "containerName shooter" | sudo tee -a conn-shooter.cfg

echo "# ----- Configuration storage" | sudo tee -a conn-academy.cfg
echo "accountName $1" | sudo tee -a conn-academy.cfg
echo "accountKey $2" | sudo tee -a conn-academy.cfg
echo "containerName academy" | sudo tee -a conn-academy.cfg

#echo "# ----- Configuration storage" | sudo tee -a conn-models.cfg
#echo "accountName $1" | sudo tee -a conn-models.cfg
#echo "accountKey $2" | sudo tee -a conn-models.cfg
#echo "containerName models" | sudo tee -a conn-models.cfg

echo "# ----- Adding azure storage account" | sudo tee -a mount.sh
#echo "sudo mount /dev/sdc1 /models" | sudo tee -a mount.sh
echo "export AZURE_STORAGE_ACCOUNT=$1" | sudo tee -a mount.sh
echo "export AZURE_STORAGE_ACCESS_KEY=$2" | sudo tee -a mount.sh
echo "sudo -H -u dev blobfuse /home/dev/instance1/stable-diffusion-webui/outputs --tmp-path=/home/dev/instance1/blobtemp --config-file=/home/dev/conn-shooter.cfg -o attr_timeout=240 -o entry_timeout=240 -o negative_timeout=120 --log-level=LOG_DEBUG --file-cache-timeout-in-seconds=120" | sudo tee -a mount.sh
echo "sudo -H -u dev blobfuse /home/dev/instance2/stable-diffusion-webui/outputs --tmp-path=/home/dev/instance2/blobtemp --config-file=/home/dev/conn-academy.cfg -o attr_timeout=240 -o entry_timeout=240 -o negative_timeout=120 --log-level=LOG_DEBUG --file-cache-timeout-in-seconds=120" | sudo tee -a mount.sh
#echo "sudo -H -u dev blobfuse /models --tmp-path=/home/dev/instance2/blobtemp --config-file=/home/dev/conn-models.cfg -o attr_timeout=240 -o entry_timeout=240 -o negative_timeout=120 --log-level=LOG_DEBUG --file-cache-timeout-in-seconds=120" | sudo tee -a mount.sh

sudo mkdir /models
sudo chmod 777 /models
sudo chmod +x mount.sh


################################### Adding autostart
cd /home/dev
echo "#!/bin/bash" | sudo tee -a rc.local
echo "sudo -H -u dev /home/dev/mount.sh" | sudo tee -a rc.local
echo "(" | sudo tee -a rc.local
echo "cd /home/dev/instance1/stable-diffusion-webui" | sudo tee -a rc.local
#echo "export PYTORCH_CUDA_ALLOC_CONF=garbage_collection_threshold:0.6, max_split_size_mb:128" | sudo tee -a rc.local
echo "export PYTORCH_CUDA_ALLOC_CONF=max_split_size_mb:9048" | sudo tee -a rc.local
echo "sudo -H -u dev ./webui.sh --api --port 7876 --xformers --listen --share --enable-insecure-extension-access --ckpt-dir /models/Stable-diffusion &" | sudo tee -a rc.local
echo ")" | sudo tee -a rc.local
echo "(" | sudo tee -a rc.local
echo "cd /home/dev/instance2/stable-diffusion-webui" | sudo tee -a rc.local
#echo "export PYTORCH_CUDA_ALLOC_CONF=garbage_collection_threshold:0.6, max_split_size_mb:128" | sudo tee -a rc.local
echo "export PYTORCH_CUDA_ALLOC_CONF=max_split_size_mb:9048" | sudo tee -a rc.local
echo "sudo -H -u dev ./webui.sh --api --port 7878 --xformers --listen --share --enable-insecure-extension-access --ckpt-dir /models/Stable-diffusion &" | sudo tee -a rc.local
echo ")" | sudo tee -a rc.local
sudo chmod +x rc.local
sudo cp rc.local /etc/rc.local


################################### Adding AZURE FUNCTIONS
cd /home/dev
sudo chown -R dev *

#sudo reboot

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

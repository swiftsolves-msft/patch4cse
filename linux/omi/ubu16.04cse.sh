# Add MSRepo
sudo curl -sSL https://packages.microsoft.com/keys/microsoft.asc
sudo apt-key add -
sudo apt-add-repository https://packages.microsoft.com/ubuntu/16.04/prod
sudo apt-get update

# Install omi release
sudo apt-get install -y omi

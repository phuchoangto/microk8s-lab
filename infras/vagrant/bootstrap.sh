
# Update the system
sudo apt-get update

# Install MicroK8s
sudo snap install microk8s --classic

# Add the current user to the 'microk8s' group
sudo usermod -a -G microk8s vagrant

# Make sure .kube directory exists
mkdir -p ~/.kube

# Allow the current user to access the MicroK8s configuration
sudo chown -f -R vagrant ~/.kube

# Create an alias for the MicroK8s kubectl command
sudo snap alias microk8s.kubectl kubectl
#!/bin/bash

# Add MSRepo
sudo rpm -Uvh https://packages.microsoft.com/config/rhel/7/packages-microsoft-prod.rpm

# Install omi release
sudo yum install -y omi

#!/bin/bash

# Add MSRepo
sudo rpm -Uvh https://packages.microsoft.com/config/sles/12/packages-microsoft-prod.rpm

# Install omi release
sudo yum install -y omi

#!/bin/bash
set -e

echo "🚀 Setting up SecureCloud-Scale-Stack prerequisites..."

# Determine OS
OS="$(uname -s)"

if [ "$OS" = "Linux" ]; then
    echo "🐧 Detected Linux OS"
    
    # Install Terraform
    if ! command -v terraform &> /dev/null; then
        echo "Installing Terraform..."
        sudo apt-get update && sudo apt-get install -y gnupg software-properties-common curl
        wget -O- https://apt.releases.hashicorp.com/gpg | gpg --dearmor | sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg > /dev/null
        gpg --no-default-keyring --keyring /usr/share/keyrings/hashicorp-archive-keyring.gpg --fingerprint
        echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] \
        https://apt.releases.hashicorp.com $(lsb_release -cs) main" | \
        sudo tee /etc/apt/sources.list.d/hashicorp.list
        sudo apt-get update && sudo apt-get install terraform
    else
        echo "✅ Terraform is already installed."
    fi

    # Install TFLint
    if ! command -v tflint &> /dev/null; then
        echo "Installing TFLint..."
        curl -s https://raw.githubusercontent.com/terraform-linters/tflint/master/install_linux.sh | bash
    else
        echo "✅ TFLint is already installed."
    fi

    # Install Checkov
    if ! command -v checkov &> /dev/null; then
        echo "Installing Checkov..."
        sudo apt-get update && sudo apt-get install -y python3-pip
        pip3 install -U checkov
    else
        echo "✅ Checkov is already installed."
    fi

elif [ "$OS" = "Darwin" ]; then
    echo "🍏 Detected macOS"
    
    if ! command -v brew &> /dev/null; then
        echo "❌ Homebrew is required but not installed. Please install Homebrew first."
        exit 1
    fi

    # Install Terraform
    if ! command -v terraform &> /dev/null; then
        echo "Installing Terraform..."
        brew tap hashicorp/tap
        brew install hashicorp/tap/terraform
    else
        echo "✅ Terraform is already installed."
    fi

    # Install TFLint
    if ! command -v tflint &> /dev/null; then
        echo "Installing TFLint..."
        brew install tflint
    else
        echo "✅ TFLint is already installed."
    fi

    # Install Checkov
    if ! command -v checkov &> /dev/null; then
        echo "Installing Checkov..."
        brew install checkov
    else
        echo "✅ Checkov is already installed."
    fi
else
    echo "❌ Unsupported OS: $OS. Please install Terraform, TFLint, and Checkov manually."
    exit 1
fi

echo "🎉 All prerequisites are installed and ready!"
echo "Run 'make help' in the project root for next steps."

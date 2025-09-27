#!/bin/bash

echo "🔑 SSH Key Configuration Verification"
echo "===================================="

# Check if SSH keys exist
echo "📋 Checking SSH key files..."
if [[ -f "ssh_key" && -f "ssh_key.pub" ]]; then
    echo "✅ SSH key pair found"
    echo "   Private key: $(ls -la ssh_key | awk '{print $1, $3, $4, $9}')"
    echo "   Public key:  $(ls -la ssh_key.pub | awk '{print $1, $3, $4, $9}')"
else
    echo "❌ SSH key pair missing"
    echo "💡 Generate with: ssh-keygen -t rsa -f ssh_key -N ''"
    exit 1
fi

# Check key permissions
echo ""
echo "🔒 Checking SSH key permissions..."
private_perms=$(stat -c "%a" ssh_key)
public_perms=$(stat -c "%a" ssh_key.pub)

if [[ "$private_perms" == "600" ]]; then
    echo "✅ Private key permissions correct (600)"
else
    echo "⚠️  Private key permissions: $private_perms (should be 600)"
    echo "💡 Fix with: chmod 600 ssh_key"
fi

if [[ "$public_perms" == "644" ]]; then
    echo "✅ Public key permissions correct (644)"
else
    echo "⚠️  Public key permissions: $public_perms (should be 644)"
    echo "💡 Fix with: chmod 644 ssh_key.pub"
fi

# Show public key fingerprint
echo ""
echo "🔍 SSH Key Fingerprint:"
ssh-keygen -lf ssh_key.pub

echo ""
echo "📝 Public Key Content:"
echo "$(cat ssh_key.pub)"

echo ""
echo "✅ SSH key verification complete!"
echo ""
echo "🚀 The keys are configured to work with:"
echo "   - VM container: ssh_key.pub is copied during build"
echo "   - Ansible: ssh_key is mounted and used for authentication"
echo "   - Connection: ansible@lightllm-vm via port 2222"


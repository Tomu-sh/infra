FROM ubuntu:22.04

# Install sudo, SSH, Docker, and other dependencies
RUN apt-get update && apt-get install -y \
    sudo \
    openssh-server \
    docker.io \
    curl \
    wget \
    netcat \
    && rm -rf /var/lib/apt/lists/*

# Create a non-root user
RUN useradd -m -s /bin/bash ansible
RUN usermod -aG sudo,docker ansible
RUN echo "ansible ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Setup SSH
RUN mkdir -p /home/ansible/.ssh
RUN chown ansible:ansible /home/ansible/.ssh
RUN chmod 700 /home/ansible/.ssh

# Copy the public key and set up authorized_keys
COPY ssh_key.pub /home/ansible/.ssh/authorized_keys
RUN chown ansible:ansible /home/ansible/.ssh/authorized_keys
RUN chmod 600 /home/ansible/.ssh/authorized_keys

# Generate SSH host keys
RUN rm -f /etc/ssh/ssh_host_*_key /etc/ssh/ssh_host_*_key.pub
RUN ssh-keygen -t rsa -f /etc/ssh/ssh_host_rsa_key -N ""
RUN ssh-keygen -t ecdsa -f /etc/ssh/ssh_host_ecdsa_key -N ""
RUN ssh-keygen -t ed25519 -f /etc/ssh/ssh_host_ed25519_key -N ""

# Configure SSH
RUN sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin no/' /etc/ssh/sshd_config
RUN sed -i 's/PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config
RUN sed -i 's/#PubkeyAuthentication yes/PubkeyAuthentication yes/' /etc/ssh/sshd_config

# Create SSH privilege separation directory
RUN mkdir -p /run/sshd

# Start Docker daemon and SSH service
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Expose SSH port and LightLLM port
EXPOSE 22 8080

CMD ["/entrypoint.sh"]

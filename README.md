# Basic VM

Use [Ansible](https://docs.ansible.com/ansible/latest/index.html) to configure a remote machine running Ubuntu 22.04 LTS.

Such that:

- A new user `agent` will be created.
- SSH login for `root` will be disabled.
- Password login over SSH will be disabled for all users. 
- The Podman equivalent of a Docker daemon will be installed and started.
- All network traffic will be blocked except for port 22 (SSH).

## Create a machine

Create a new VM with your favourite cloud provider running a fresh install of `Ubuntu 22.04 LTS`.

This repo expects you to have `root` access via SSH.  

This README assumes the filename `~/.ssh/id_ed25519-root` for the `root` private-key file.

## Local setup

### /etc/hosts

*Before you continue*

Add the remote machine to your local `/etc/hosts` file (replace `0.0.0.0` with the actual IP).

```
0.0.0.0 vm01
```

**Note**: You can skip this step if you have a domain name registered for your VM (e.g. `example.com`).

### SSH

#### The root user

*Before you continue*

Update your local `~/.ssh/config` file.

```
Match user root host vm01
    IdentityFile ~/.ssh/id_ed25519-root
```

Add the `root` private key to your SSH-agent.

```
ssh-add ~/.ssh/id_ed22519-root
```

Login over SSH as `root` to verify it works.

```
ssh root@vm01
```

#### The agent user

A new user `agent` will be created on the remote machine after you complete step 1 (see below).

*Before you continue*

Create a SSH key-pair for the new user `agent`.

```
ssh-keygen -t ed25519 -f ~/.ssh/id_ed25519-agent -C agent
```

Update your local `~/.ssh/config` file.

```
Match user agent host vm01
    IdentityFile ~/.ssh/id_ed25519-agent
```

Add the `agent` private key to your SSH-agent.

```
ssh-add ~/.ssh/id_ed22519-agent
```

### Ansible

Ansible needs to know about your remote machine.

*Before you continue*

Create the file `inventory.yaml` in the root folder of this repo.

```
ungrouped:
  hosts:
    vm01:
      ansible_host: vm01
```

## Remote setup

### Step 1

Step 1 will be run as `root`.

Step 1 will create the user `agent` on the remote machine and disable `root` login.

The new user `agent` needs a `sudo` password. Ansible requires the provided password to be in an encrypted form. Here `$(mkpasswd --method=sha-512)` is used.

*Before you continue*

Run the playbook `playbooks/01_user.yaml` to complete step 1. 

```
ansible-playbook -i inventory.yaml --extra-vars "agent_password=$(mkpasswd --method=sha-512)" playbooks/01_user.yaml
```

### Step 2

Step 2 will be run as `agent`.

You will be prompted for the `sudo` password you provided in step 1.

Step 2 will install Podman and setup a Firewall on the remote machine.

*Before you continue*

Run the remaining playbooks to complete step 2.

```
ansible-playbook -i inventory.yaml --ask-become-pass playbooks/0[2-4]*.yaml
```

## Test it

### SSH

Connect to the remote machine with the user `agent`.

```
ssh agent@vm01
```

### Podman

Create a new remote Podman connection on your local machine.

```
podman system connection add vm01 ssh://agent@vm01/run/user/1000/podman/podman.sock
```

Run a Podman command on the the remote machine.

```
podman -r -c vm01 version
```

**Ok, all done!**

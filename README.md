# Basic VM

Use Ansible to configure a remote machine running Ubuntu 22.04 LTS.

Such that:

- A new user `agent` will be created.
- SSH login for `root` will be disabled.
- Password login over SSH will be disabled for all users. 
- The Podman equivalent of a Docker daemon will be installed and started.
- All network traffic will be blocked except for port 22 (SSH).

## Preparations

### VM

Create a new machine with your favourite cloud provider running Ubuntu 22.04 LTS.

This repo (and README) assumes a you can login to the remote machine as `root`.  

Some cloud providers provide a user with `sudo` rights instead of a `root` user. Details may vary.

This README uses `~/.ssh/id_ed25519-root` as the filename for the `root` private-key file. You can use any filename.

### /etc/hosts

*Before you continue*

Add the remote machine to your local `/etc/hosts` file (replace `0.0.0.0` with its actual IP).

```
0.0.0.0 vm01
```

### SSH

#### The root user

*Before you continue*

Update your local `~/.ssh/config` file.

```
Match user root host vm01
    IdentityFile ~/.ssh/id_ed25519-root
```

Add the `root` key to your local SSH-agent.

```
ssh-add ~/.ssh/id_ed22519-root
```

Login over SSH as `root` (as a test).

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

Add the `agent` key to your local SSH-agent.

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

## Setup the remote machine

### Step 1

Step 1 will create the user `agent` on the remote machine and disable `root` login.

Step 1 will be run as `root`.

The new user `agent` needs a `sudo` password. Ansible requires the provided password to be in an encrypted form. Here `$(mkpasswd --method=sha-512)` is used.

*Before you continue*

Run the playbook `playbooks/01_user.yaml` to complete step 1. 

```
ansible-playbook -i inventory.yaml --extra-vars "agent_password=$(mkpasswd --method=sha-512)" playbooks/01_user.yaml
```

### Step 2

Step 2 will install Podman and setup a Firewall on the remote machine.

Step 2 will be run as the `agent` user. You will be prompted for the `sudo` password you provided in step 1.

*Before you continue*

Run the remaining playbooks to complete step 2.

```
ansible-playbook -i inventory.yaml --ask-become-pass playbooks/0[2-4]*.yaml
```

## Test your setup

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

Ok, done!

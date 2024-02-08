# Basic VM

Use Ansible to configure a remote machine running Ubuntu 22.04 LTS.

Such that:

- SSH login for `root` will be disabled.
- A new user `agent` will be created with SSH access (no password, key only).
- A Podman daemon will be running.
- A Firewall will block traffic on all ports except on port 22 (SSH).

## Preparations

### VM

Create a new machine with your favourite cloud provider running Ubuntu 22.04 LTS.

### /etc/hosts

Add the remote machine to your local `/etc/hosts` file.

```
0.0.0.0 vm01
```

### SSH

#### The root user

You should have `root` access to your remote machine.

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

A new user `agent` will be created on the remote machine when you run the Ansible script.

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

Create the file `inventory.yaml`.

```
ungrouped:
  hosts:
    vm01:
      ansible_host: vm01
```

## Setup the remote machine

### Step 1

Step 1 will create the user `agent` on the remote machine and disable `root` login.

The `agent` user needs a `sudo` password. Ansible requires the provided password to be in an encrypted form. Here `$(mkpasswd --method=sha-512)` is used.

Login with user `agent` will still require a key.

Run the playbook `playbooks/01_user.yaml` to complete step 1. 

```
ansible-playbook -i inventory.yaml --extra-vars "agent_password=$(mkpasswd --method=sha-512)" playbooks/01_user.yaml
```

### Step 2

Step 2 will install Podman and setup a Firewall on the remote machine.

Step 2 will be run as the `agent` user. You will be prompted for the `sudo` password you provided in step 1.

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

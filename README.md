# Basic VM

Use Ansible to configure a remote machine running Ubuntu 22.04 LTS.

Such that:

- SSH login for the user `root` will be disabled.
- A new user `agent` will be created with SSH-login (no password, key only) enabled.
- A Podman daemon will be running.

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

Run the playbook `playbooks/01_user.yaml`. 

This playbook will create the user `agent` on the remote machine.

The `agent` user needs a `sudo` password. Ansible requires the provided password to be in an encrypted form. Here `$(mkpasswd --method=sha-512)` is used.

Login over SSH will still required a key.

```
ansible-playbook -i inventory.yaml --extra-vars "agent_password=$(mkpasswd --method=sha-512)" playbooks/01_user.yaml
```

At this point the `agent` user has been created and `root` login has been disabled.

### Step 2

Run all other playbooks. 

These playbooks will setup the firewall and add Podman to the remote machine.

You will be prompted for the `sudo` password you provided in step 1.

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

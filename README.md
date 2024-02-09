# Basic VM

Use [Ansible](https://docs.ansible.com/ansible/latest/index.html) to configure a remote machine running Ubuntu 22.04 LTS.

Such that:

- A new user `agent` will be created.
- SSH login for `root` will be disabled.
- Password login over SSH will be disabled for all users. 
- The Podman equivalent of a Docker daemon will be installed and started.
- All network traffic will be blocked except for port 22 (SSH).

## Create the VM

Create a new VM with your favourite cloud provider running a fresh install of `Ubuntu 22.04 LTS`.

You should have `root` access to the VM using SSH and a private key.

*Before you continue, test your connection*

```
ssh -i <ROOT-PRIVATE-KEY-FILE> root@<VM-IP> 
```

## Register a domain

Register a domain (e.g `example.com`) with your favourite domain registrar.

*Before you continue*

Add a top-domain A Record.

| Host  | TTL  | Data          |
|-------|------|---------------|
| @     | 3600 | IP of your VM |

Add a wildcard sub-domain A Record.

| Host  | TTL  | Data          |
|-------|------|---------------|
| *     | 3600 | IP of your VM |

*Wait a while, then test your domain*

```
ping <DOMAIN>
```

## Local setup

### SSH

A new user `agent` will be created on the VM after you complete step 1.

To be able to login as the user `agent`, you need to create a new SSH key pair.

*Before you continue*

Create a new key pair for the user `agent`.

```
ssh-keygen -t ed25519 -f ~/.ssh/id_ed25519-agent -C agent
```

Update your local `~/.ssh/config` file.

```
Match user agent host <DOMAIN>
    IdentityFile ~/.ssh/id_ed25519-agent
```

Add the `agent` private key to your SSH-agent.

```
ssh-add ~/.ssh/id_ed22519-agent
```

### Ansible

Ansible needs to know about your VM.

*Before you continue*

Create the file `inventory.yaml` in the root folder of this repo.

```
ungrouped:
  hosts:
    vm:
      ansible_host: <DOMAIN>
```

## Remote setup

### Step 1

Step 1 will be run as `root` on the VM.

After this step is completed, a new user `agent` will have been created  and `root` login will have been disabled.

The user `agent` needs a password. The password needs to be provided in an encrypted form. Here `$(mkpasswd --method=sha-512)` is used.

*Before you continue*

Run the playbook `playbooks/01_user.yaml` to complete step 1. 

```
ansible-playbook -i inventory.yaml --key-file <ROOT-PRIVATE-KEY-FILE> --extra-vars "agent_password=$(mkpasswd --method=sha-512)" playbooks/01_user.yaml
```

*Then, test your access*.

```
ssh agent@<DOMAIN>
```

### Step 2

Step 2 will be run as `agent` on the VM.

Ansible will prompt you for the password you provided in step 1.

After this step is complete, Podman will have been installed and started on the VM.

*Before you continue*

Run the remaining playbooks.

```
ansible-playbook -i inventory.yaml --ask-become-pass playbooks/0[2-4]*.yaml
```

*Then test your podman setup*

Create a new remote Podman connection.

```
podman system connection add vm ssh://agent@<DOMAIN>/run/user/1000/podman/podman.sock
```

Then issue a remote command.

```
podman -r -c vm version
```

**Ok, all done!**

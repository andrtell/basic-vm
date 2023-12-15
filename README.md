# Basic VM

Basic VM

## SSH Setup

Add the IP of your VM to `/etc/hosts`.

```
0.0.0.0 vm01
```

Create SSH-keys for the `agent` user.

```
ssh-keygen -t ed25519 -f ~/.ssh/id_ed25519-agent -C agent
```

Update your `~/.ssh/config`.

```
Match user root host vm01
    IdentityFile ~/.ssh/id_ed25519-root

Match user agent host vm01
    IdentityFile ~/.ssh/id_ed25519-agent
```

Add your keys to the SSH-agent.

```
ssh-add ~/.ssh/id_ed22519-root
```

```
ssh-add ~/.ssh/id_ed22519-agent
```

## Ansible

Create the file `inventory.yaml`.

```
ungrouped:
  hosts:
    vm01:
      ansible_host: vm01
```

## Basic VM

Run the playbook `playbooks/01_user.yaml`. This will create the `agent` user on the VM.

```
ansible-playbook -i inventory.yaml --extra-vars "agent_password=$(mkpasswd --method=sha-512)" playbooks/01_user.yaml
```

Run all other playbooks.

```
ansible-playbook -i inventory.yaml --ask-become-pass playbooks/0[2-3]*.yaml
```

## SSH

Connect to the VM using SSH

```
ssh agent@vm01
```

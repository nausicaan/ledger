# Ledger

Ledger is an Ansible playbook which, together with multiple Ruby scripts, gathers and saves meta data relating to a WordPress users site specific accounts.

![Ledger](ledger.jpg)

*Image by [Freepik](https://www.freepik.com/author/freepik) on [freepik.com](https://www.freepik.com)*

## Prerequisites

Variables declared in a defaults/main.yaml file:

- WPATH: Path to the wordpress installation.
- GIT: Local path to the git repository.
- TEST: WordPress test server root domain.
- PROD: WordPress production server root domain.

```console
- name: Create a list of user/sites
  hosts: chimera
  vars_files: defaults/main.yaml
  gather_facts: false
  ignore_errors: true
  tasks:
    - name: Compile the user data
      ansible.builtin.script:
        cmd: "{{ GIT }}accounts.rb {{ WPATH }} {{ TEST }}"

    - name: Download the compendium.yaml file
      ansible.builtin.fetch:
        src: yaml/compendium.yaml
        dest: "{{ GIT }}results/"
        flat: true
```

## Run

Navigate to the folder containing your *accounts.yaml* file and (dependent on the location of your inventory file) run:

```console
ansible-playbook -i ~/inventory.yaml accounts.yaml
```

**Note**: Playbooks *source.yaml* and *reference.yaml* need to be run at least once prior to *accounts.yaml* to build the dependent files.

## Output

Outputs a file named *compendium.yaml*. This file contains a complete list of all WordPress users, any sites they have an account on, their role for that site, and last login time, if found. Login timestamps are stored in Unix epoch time.

## License

Code is distributed under [The Unlicense](https://github.com/nausicaan/free/blob/main/LICENSE.md) and is part of the Public Domain.
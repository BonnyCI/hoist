=======
SeedCI
=======

Installer for running CI as a service.

Running
=======

1. Add dns entries for nodepool and zuul (possibly using /etc/hosts) and use
the inventory file at `inventory/hosts`.  Services may deployed onto one node
or across mulitple nodes.

2. Setup a secrets yaml (see secrets.yml.example). TODO: Store these somewhere
sane.

3. Pull ansible role dependencies:

    $ ansible-galaxy install -r requirements.yml

3. Run playbook::

    $ ansible-playbook -i hosts -e @secrets.yml site.yml

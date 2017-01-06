=======
Hoist
=======

Installer for running CI as a service.

Running
=======

1. Add dns entries for nodepool and zuul (possibly using /etc/hosts) and use
the inventory file at `inventory/ci`.  Services may be deployed onto one node
or across mulitple nodes.

2. Setup a secrets yaml (see secrets.yml.example). TODO: Store these somewhere
sane.

3. Run playbook::

    $ ansible-playbook -i hosts -e @secrets.yml site.yml

Bastion
=======

To create a new bastion in a cloud for automating things follow these steps:

1. Setup your local (to your development enviroment) clouds.yml with access to the new cloud.

2. Add new bastion to provision.yml, adding a tag for the new cloud.

   Bastion nodes should be Ubuntu Xenial 16.04

3. Run this to just provision the new one::

   $ ansible-playbook -i localhost, provision.yml -t new_cloud_tag

4. SSH to the new instance and put /etc/secrets.yml in place.

5. Set ownership on secrets files::

   $ sudo chown root.root /etc/secrets.yml

6. Add the new bastion host to inventory/bastions

7. Run bastion.yml playbook::

   $ ansible-playbook -i inventory/bastions bastion.yml -e @secrets.yml

After that the bastion should self-manage, and logs should be visible at http://<<bastion>>/cron-logs/

Updating Secrets
================
As we add or adjust secrets, we'll need to update the secrets file that lives on bastion hosts. As always, if introducing a new secret, update our example secrets file in this repo first. Then update the running bastion.


Testing with Vagrant
====================
You can use vagrant to exercise the ansible paths for `bastion.yml` and `install-ci.yml`.

First, install vagrant with the hostmanager and triggers plugins. The hostmanager
plugin is used to manage /etc/hosts on the VMs, and the triggers plugin is
used to run commands on the host after specified actions -- in our case to
run commands in the bastion VM after actions to other VMs.::

   $ sudo apt-get install vagrant
   $ vagrant plugin install vagrant-hostmanager
   $ vagrant plugin install vagrant-triggers

To perform a full deploy::

   $ vagrant up

To redeploy just the nodepool VM::

   $ vagrant destroy nodepool
   $ vagrant up nodepool

To inspect the zuul VM::

   $ vagrant ssh zuul
   $ # netstat, tcpdump, tail logs, etc.
   $ logout

To tear down the entire stack when you're done::

   $ vagrant destroy


DON'T MERGE THIS - WE JUST NEED SOMETHING TO CHECK

Contributing
============

See `CONTRIBUTING.md <CONTRIBUTING.md>`_ in this repository.

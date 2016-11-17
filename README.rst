=======
Hoist
=======

Installer for running CI as a service.

Running
=======

1. Add dns entries for nodepool and zuul (possibly using /etc/hosts) and use
the inventory file at `inventory/hosts`.  Services may deployed onto one node
or across mulitple nodes.

2. Setup a secrets yaml (see secrets.yml.example). TODO: Store these somewhere
sane.

3. Run playbook::

    $ ansible-playbook -i hosts -e @secrets.yml site.yml

Bastion
=======

To create a new bastion in a cloud for automating things follow these steps:

1. Setup clouds.yml with access to the new cloud.

2. Add new bastion to provision.yml, adding a tag for the new cloud.

   Bastion nodes should be Ubuntu Xenial 16.04

3. Run this to just provision the new one.

   $ ansible-playbook -i localhost, provision.yml -t new_cloud_tag

4. SSH into new cloud instance and create a github deploy key:

   $ ssh-keygen -t rsa -b 4096

5. Add the deploy key to deploy keys on https://github.com/BonnyCI/hoist

6. Add the new bastion host to inventory/bastions

7. Run bastion.yml playbook:

   $ ansible-playbook -i inventory/bastions bastion.yml

After that the bastion should self-manage, and logs should be visible at http://<<bastion>>/cron-logs/

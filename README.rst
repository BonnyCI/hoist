=======
SeedCI
=======

Installer for running CI as a service.

Running
=======

1. Create a inventory file, for example an all-in-one install::

    $ cat >hosts <<END
    [zuul]
    10.0.0.241

    [nodepool]
    10.0.0.241
    END

OR

Add dns entries for nodepool and zuul (possibly using /etc/hosts) and use the
inventory file at `inventory/hosts`.

2. Setup a secrets yaml (see secrets.yml.example). TODO: Store these somewhere
sane.

3. Pull ansible role dependencies:

    $ ansible-galaxy install -r requirements.yml

3. Run playbook::

    $ ansible-playbook -i hosts -e @secrets.yml site.yml

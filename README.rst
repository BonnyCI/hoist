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

2. Pull ansible role dependencies::

    $ ansible-galaxy install -r requirements.yml

3. Run playbook::

    $ ansible-playbook -i hosts site.yml

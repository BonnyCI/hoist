Pip
===

Install the latest version of pip.

Role Variables
--------------

Defaults:

- `pip_cache_dir`: The directory that the `get-pip.py` bootstrapper will be downloaded to. Defaults to `/var/cache/pip-installer`.
- `pip_install_url`: The url to download the `get-pip.py` bootstrapper. Defaults to `https://bootstrap.pypa.io/get-pip.py`.

Example Playbook
----------------

Including an example of how to use your role (for instance, with variables passed in as parameters) is always nice for users too:

    - hosts: servers
      roles:
         - role: pip

License
-------

Apache 2

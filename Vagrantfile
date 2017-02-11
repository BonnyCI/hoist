# All Vagrant configuration is done below. The "2" in Vagrant.configure
# configures the configuration version (we support older styles for
# backwards compatibility). Please don't change it unless you know what
# you're doing.
Vagrant.configure(2) do |config|
  if Vagrant.has_plugin?("vagrant-hostmanager")
    # https://github.com/smdahlen/vagrant-hostmanager
    config.hostmanager.enabled = true
    config.hostmanager.manage_host = false
    config.hostmanager.manage_guest = true
    config.hostmanager.include_offline = true
  else
    # Exit, informing the user they are missing an important plugin
    puts "You don't have the vagrant-hostmanager plugin installed, please run `vagrant plugin install vagrant-hostmanager`"
    exit 2
  end

  if !Vagrant.has_plugin?("vagrant-triggers")
    # https://github.com/emyl/vagrant-triggers
    # Exit, informing the user they are missing an important plugin
    puts "You don't have the vagrant-triggers plugin installed, please run `vagrant plugin install vagrant-triggers`"
    exit 2
  end

  config.vm.box = 'ubuntu/xenial64'

  config.vm.synced_folder ".", "/vagrant"

  config.vm.define :bastion do |bastion|
    bastion.vm.hostname = 'bastion.vagrant'
    bastion.vm.network "private_network", ip: "10.0.0.10"

    bastion.vm.provider "virtualbox" do |v|
      v.memory = '1024'
    end

    bastion.vm.network "forwarded_port", guest: 80, host: 8080

    bastion.vm.provision "shell", path: "tools/install-pip.sh"
    bastion.vm.provision "shell", inline: <<-SHELL
      # Install some dependencies
      apt-get update
      apt-get -y install build-essential python python-dev libffi-dev libssl-dev
      pip install ansible

      # Move the example secrets file in place
      if test -f /etc/secrets.yml ; then
        rm /etc/secrets.yml
      fi
      cp /vagrant/secrets.yml.example /etc/secrets.yml

      # disable cron runs, run ansible manually while testing
      touch /etc/disable-ansible-runner-cideploy
      touch /etc/disable-ansible-runner-system-ansible
    SHELL

    bastion.vm.provision "shell", inline: "ansible-galaxy install --roles-path /vagrant/upstream_roles -r /vagrant/requirements.yml"

    bastion.vm.provision "ansible_local" do |ansible|
      ansible.inventory_path = "/vagrant/inventory/vagrant"
      ansible.playbook = "/vagrant/bastion.yml"
      ansible.raw_arguments = [ "--skip-tags 'monitoring'",
                                "-e @/etc/secrets.yml",
                                "-vv" ]
      ansible.sudo = true
    end
  end

  config.vm.define :zuul do |zuul|
    zuul.vm.hostname = 'zuul.vagrant'
    zuul.vm.network "private_network", ip: "10.0.0.100"

    zuul.vm.provider "virtualbox" do |v|
      v.memory = '1024'
    end

    zuul.vm.network "forwarded_port", guest: 4730, host: 4730

    zuul.vm.provision "shell", path: "tools/install-pip.sh"
    zuul.vm.provision "shell", path: "tools/vagrant-inject-pubkey.sh"

    zuul.trigger.after [:up, :provision] do
      run "vagrant ssh bastion -c 'sudo -i -u cideploy ssh -o StrictHostKeyChecking=no ubuntu@zuul.vagrant true'"
      run "vagrant ssh bastion -c 'sudo -i -u cideploy /vagrant/tools/vagrant-run-ansible.sh --limit zuul'"
    end

    zuul.trigger.after :destroy do
      run "vagrant ssh bastion -c 'sudo -i -u cideploy ssh-keygen -f /home/cideploy/.ssh/known_hosts -R zuul.vagrant'"
      run "vagrant ssh bastion -c 'sudo -i -u cideploy ssh-keygen -f /home/cideploy/.ssh/known_hosts -R 10.0.0.100'"
    end
  end

  config.vm.define :nodepool do |nodepool|
    nodepool.vm.hostname = 'nodepool.vagrant'
    nodepool.vm.network "private_network", ip: "10.0.0.101"

    nodepool.vm.provider "virtualbox" do |v|
      v.memory = '1024'
    end

    nodepool.vm.provision "shell", path: "tools/install-pip.sh"
    nodepool.vm.provision "shell", path: "tools/vagrant-inject-pubkey.sh"

    nodepool.trigger.after [:up, :provision] do
      run "vagrant ssh bastion -c 'sudo -i -u cideploy ssh -o StrictHostKeyChecking=no ubuntu@nodepool.vagrant true'"
      run "vagrant ssh bastion -c 'sudo -i -u cideploy /vagrant/tools/vagrant-run-ansible.sh --limit nodepool'"
    end

    nodepool.trigger.after :destroy do
      run "vagrant ssh bastion -c 'sudo -i -u cideploy ssh-keygen -f /home/cideploy/.ssh/known_hosts -R nodepool.vagrant'"
      run "vagrant ssh bastion -c 'sudo -i -u cideploy ssh-keygen -f /home/cideploy/.ssh/known_hosts -R 10.0.0.101'"
    end
  end

  config.vm.define :logs do |logs|
    logs.vm.hostname = 'logs.vagrant'
    logs.vm.network "private_network", ip: "10.0.0.102"

    logs.vm.provider "virtualbox" do |v|
      v.memory = '2048'
    end

    logs.vm.provision "shell", path: "tools/install-pip.sh"
    logs.vm.provision "shell", path: "tools/vagrant-inject-pubkey.sh"

    logs.trigger.after [:up, :provision] do
      run "vagrant ssh bastion -c 'sudo -i -u cideploy ssh -o StrictHostKeyChecking=no ubuntu@logs.vagrant true'"
      run "vagrant ssh bastion -c 'sudo -i -u cideploy /vagrant/tools/vagrant-run-ansible.sh --limit log'"
    end

    logs.trigger.after :destroy do
      run "vagrant ssh bastion -c 'sudo -i -u cideploy ssh-keygen -f /home/cideploy/.ssh/known_hosts -R logs.vagrant'"
      run "vagrant ssh bastion -c 'sudo -i -u cideploy ssh-keygen -f /home/cideploy/.ssh/known_hosts -R 10.0.0.102'"
    end
  end

  config.vm.define :merger do |merger|
    merger.vm.hostname = 'merger.vagrant'
    merger.vm.network "private_network", ip: "10.0.0.103"

    merger.vm.provider "virtualbox" do |v|
      v.memory = '1024'
    end

    merger.vm.provision "shell", path: "tools/install-pip.sh"
    merger.vm.provision "shell", path: "tools/vagrant-inject-pubkey.sh"

    merger.trigger.after [:up, :provision] do
      run "vagrant ssh bastion -c 'sudo -i -u cideploy ssh -o StrictHostKeyChecking=no ubuntu@merger.vagrant true'"
      run "vagrant ssh bastion -c 'sudo -i -u cideploy /vagrant/tools/vagrant-run-ansible.sh --limit mergers'"
    end

    merger.trigger.after :destroy do
      run "vagrant ssh bastion -c 'sudo -i -u cideploy ssh-keygen -f /home/cideploy/.ssh/known_hosts -R merger.vagrant'"
      run "vagrant ssh bastion -c 'sudo -i -u cideploy ssh-keygen -f /home/cideploy/.ssh/known_hosts -R 10.0.0.103'"
    end
  end

end

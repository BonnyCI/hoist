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

  INSTALL_PIP = <<-SHELL
    if ! which python ; then
      apt-get update
      apt-get -y install python
    fi

    if ! which pip ; then
      wget -O get-pip.py https://bootstrap.pypa.io/get-pip.py
      python get-pip.py
    fi
  SHELL

  config.vm.define :bastion do |bastion|
    bastion.vm.hostname = 'bastion.vagrant'
    bastion.vm.network "private_network", ip: "10.0.0.10"

    bastion.vm.provider "virtualbox" do |v|
      v.memory = '1024'
    end

    bastion.vm.network "forwarded_port", guest: 80, host: 8080

    bastion.vm.provision "shell", inline: INSTALL_PIP
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
    SHELL

    bastion.vm.provision "ansible_local" do |ansible|
      ansible.inventory_path = "/vagrant/inventory/vagrant"
      ansible.playbook = "/vagrant/bastion.yml"
      ansible.raw_arguments = [ "--skip-tags 'monitoring'",
                                "-e @/etc/secrets.yml",
                                "-vv" ]
      ansible.sudo = true
    end
  end

  INJECT_CIDEPLOY_PUBKEY = <<-SHELL
    pip install shyaml
    PUBKEY=$(cat /vagrant/secrets.yml.example | shyaml get-value secrets.ssh_keys.cideploy.public)
    if grep -q "$PUBKEY" ~ubuntu/.ssh/authorized_keys ; then
      echo Key already authorized
    else
      echo "\n$PUBKEY" >> ~ubuntu/.ssh/authorized_keys
    fi
  SHELL

  config.vm.define :zuul do |zuul|
    zuul.vm.hostname = 'zuul.vagrant'
    zuul.vm.network "private_network", ip: "10.0.0.100"

    zuul.vm.provider "virtualbox" do |v|
      v.memory = '1024'
    end

    zuul.vm.network "forwarded_port", guest: 4730, host: 4730

    zuul.vm.provision "shell", inline: INSTALL_PIP
    zuul.vm.provision "shell", inline: INJECT_CIDEPLOY_PUBKEY

    zuul.trigger.after [:up, :provision] do
      run "vagrant ssh bastion -c 'sudo -i -u cideploy ssh -o StrictHostKeyChecking=no ubuntu@zuul.vagrant true'"
      run "vagrant ssh bastion -c 'sudo -i -u cideploy ansible-playbook -i /vagrant/inventory/vagrant /vagrant/install-ci.yml -e @/etc/secrets.yml --skip-tags monitoring --limit zuul'"
    end

    zuul.trigger.after :destroy do
      run "vagrant ssh bastion -c 'sudo -i -u cideploy ssh-keygen -f /home/cideploy/.ssh/known_hosts -R zuul.vagrant'"
    end
  end

  config.vm.define :nodepool do |nodepool|
    nodepool.vm.hostname = 'nodepool.vagrant'
    nodepool.vm.network "private_network", ip: "10.0.0.101"

    nodepool.vm.provider "virtualbox" do |v|
      v.memory = '1024'
    end

    nodepool.vm.provision "shell", inline: INSTALL_PIP
    nodepool.vm.provision "shell", inline: INJECT_CIDEPLOY_PUBKEY

    nodepool.trigger.after [:up, :provision] do
      run "vagrant ssh bastion -c 'sudo -i -u cideploy ssh -o StrictHostKeyChecking=no ubuntu@nodepool.vagrant true'"
      run "vagrant ssh bastion -c 'sudo -i -u cideploy ansible-playbook -i /vagrant/inventory/vagrant /vagrant/install-ci.yml -e @/etc/secrets.yml --skip-tags monitoring --limit nodepool'"
    end

    nodepool.trigger.after :destroy do
      run "vagrant ssh bastion -c 'sudo -i -u cideploy ssh-keygen -f /home/cideploy/.ssh/known_hosts -R nodepool.vagrant'"
    end
  end

  config.vm.define :zm01 do |zm01|
    zm01.vm.hostname = 'zm01.vagrant'
    zm01.vm.network "private_network", ip: "10.0.0.102"

    zm01.vm.provider "virtualbox" do |v|
      v.memory = '1024'
    end

    zm01.vm.provision "shell", inline: INSTALL_PIP
    zm01.vm.provision "shell", inline: INJECT_CIDEPLOY_PUBKEY

    zm01.trigger.after [:up, :provision] do
      run "vagrant ssh bastion -c 'sudo -i -u cideploy ssh -o StrictHostKeyChecking=no ubuntu@zm01.vagrant true'"
      run "vagrant ssh bastion -c 'sudo -i -u cideploy ansible-playbook -i /vagrant/inventory/vagrant /vagrant/install-ci.yml -e @/etc/secrets.yml --skip-tags monitoring --limit zuul_merger'"
    end

    zm01.trigger.after :destroy do
      run "vagrant ssh bastion -c 'sudo -i -u cideploy ssh-keygen -f /home/cideploy/.ssh/known_hosts -R zm01.vagrant'"
      run "vagrant ssh bastion -c 'sudo -i -u cideploy ssh-keygen -f /home/cideploy/.ssh/known_hosts -R 10.0.0.102'"
    end
  end

  config.vm.define :logs do |logs|
    logs.vm.hostname = 'logs.vagrant'
    logs.vm.network "private_network", ip: "10.0.0.103"

    logs.vm.provider "virtualbox" do |v|
      v.memory = '1024'
    end

    logs.vm.provision "shell", inline: INSTALL_PIP
    logs.vm.provision "shell", inline: INJECT_CIDEPLOY_PUBKEY

    logs.trigger.after [:up, :provision] do
      run "vagrant ssh bastion -c 'sudo -i -u cideploy ssh -o StrictHostKeyChecking=no ubuntu@logs.vagrant true'"
      run "vagrant ssh bastion -c 'sudo -i -u cideploy ansible-playbook -i /vagrant/inventory/vagrant /vagrant/install-ci.yml -e @/etc/secrets.yml --skip-tags monitoring --limit log'"
    end

    logs.trigger.after :destroy do
      run "vagrant ssh bastion -c 'sudo -i -u cideploy ssh-keygen -f /home/cideploy/.ssh/known_hosts -R logs.vagrant'"
      run "vagrant ssh bastion -c 'sudo -i -u cideploy ssh-keygen -f /home/cideploy/.ssh/known_hosts -R 10.0.0.102'"
    end
  end

end

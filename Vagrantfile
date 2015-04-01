# vim: set ft=ruby :

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
    if Vagrant.has_plugin?("vagrant-cachier")
        config.cache.scope = :box
    end

    config.vm.hostname = "ubuntu"
    config.vm.box      = "opscode-ubuntu-14.04"
    config.vm.box_url  = "http://opscode-vm-bento.s3.amazonaws.com/vagrant/virtualbox/opscode_ubuntu-14.04_chef-provisionerless.box"
    #config.vm.network :private_network, ip: "192.168.0.2"
    #(49008..49908).each do |port|
    #   config.vm.network :forwarded_port, :host => port, :guest => port
    #end
    config.vm.network :forwarded_port, guest: 22, host: 2028, auto_correct: true
    config.vm.synced_folder ".", "/vagrant", disabled: true

    config.vm.provider "virtualbox" do |vb|
        vb.name = "ubuntu-precise-64"
        vb.customize ["modifyvm", :id, "--memory", "1024"]
    end

    # bootstrapping
    #config.vm.provision :shell, path: "bootstrap.sh"

    # install or update chef
    config.omnibus.chef_version = :latest

    # run chef-solo
    config.vm.provision :chef_solo do |chef|
        chef.custom_config_path = "Vagrantfile.chef"
        chef.cookbooks_path = ["cookbooks", "site-cookbooks"]
        #chef.data_bags_path = "data_bags"
        chef.json = {
            "local" => {
                "user"  => "vagrant",
                "group" => "vagrant"
            }
        }

        chef.run_list = %w[
            recipe[env::base]
            recipe[env::setup]
            recipe[lang::ruby]
            recipe[lang::php]
            recipe[nginx]
        ]
    end
end


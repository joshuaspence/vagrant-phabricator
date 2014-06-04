#!/usr/bin/env ruby

Vagrant.configure('2') do |config|
  config.vm.box = 'hashicorp/precise64'

  config.vm.synced_folder '.', '/vagrant', :disabled => true

  config.vm.provider :virtualbox do |virtualbox|
    virtualbox.cpus = 1
    virtualbox.memory = 512
    virtualbox.customize [
      'modifyvm', :id,
      '--cpuexecutioncap', 50,
      '--natdnshostresolver1', 'on',
      '--natdnsproxy1', 'on',
    ]
  end

  config.vm.provision :shell, inline: 'apt-get update'

  config.vm.provision :puppet do |puppet|
    puppet.module_path = 'modules'
    puppet.manifest_file = 'site.pp'
    puppet.options = ['--verbose']
  end

  config.vm.define :app do |config|
    config.vm.hostname = 'phabricator.joshuaspence.com'
    config.vm.network :private_network, ip: '10.0.0.100'

    config.vm.provider :virtualbox do |virtualbox|
      virtualbox.name = 'Phabricator'
    end
  end
end

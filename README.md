vagrant-phabricator
===================
This repository contains a [Vagrantfile](Vagrantfile) and [Puppet module](puppet-phabricator) for provisioning [Phabricator][Phabricator] Virtual Machines.

Requirements
============
The following [Vagrant][Vagrant] plugins are required:

* [vagrant-librarian-puppet](https://github.com/mindreframer/vagrant-puppet-librarian)

Additionally, the following [Vagrant][Vagrant] plugins are recommended:

* [vagrant-hostmanager](https://github.com/smdahlen/vagrant-hostmanager)
* [vagrant-vbquest](https://github.com/dotless-de/vagrant-vbguest)

Usage
=====
To get started, simply run `vagrant up`.

[Phabricator]: <http://phabricator.org/>
[Puppet]: <http://puppetlabs.com/>
[Vagrant]: <http://www.vagrantup.com/>

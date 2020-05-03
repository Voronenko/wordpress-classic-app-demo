require_relative 'deployment/vagrant/lib/vagrant'

# Absolute paths on the host machine.
host_vm_dir = File.dirname(File.expand_path(__FILE__))
host_project_dir = ENV['VM_PROJECT_ROOT'] || host_vm_dir
host_config_dir = ENV['VM_CONFIG_DIR'] ? "#{host_project_dir}/#{ENV['VM_CONFIG_DIR']}" : host_project_dir

# Absolute paths on the guest machine.
guest_project_dir = '/vagrant'
guest_vm_dir = ENV['VM_DIR'] ? "/vagrant/#{ENV['VM_DIR']}" : guest_project_dir
guest_config_dir = ENV['VM_CONFIG_DIR'] ? "/vagrant/#{ENV['VM_CONFIG_DIR']}" : guest_project_dir

vm_env = ENV['VM_ENV'] || 'vagrant'

default_config_file = "#{host_vm_dir}/deployment/vagrant/vagrant_config.yml"
unless File.exist?(default_config_file)
  raise_message "Configuration file not found! Expected in #{default_config_file}"
end

vconfig = load_config([
  default_config_file,
  "#{host_config_dir}/config.yml",
  "#{host_config_dir}/#{vm_env}.config.yml",
  "#{host_config_dir}/local.config.yml"
])

ensure_plugins(vconfig['vagrant_plugins'])

Vagrant.configure("2") do |config|

    config.vm.define vconfig['vagrant_machine_name']
    # Networking configuration.
    config.vm.hostname = vconfig['vagrant_hostname']
    config.vm.network :private_network,
      ip: vconfig['vagrant_ip'],
      auto_network: vconfig['vagrant_ip'] == '0.0.0.0' && Vagrant.has_plugin?('vagrant-auto_network')

    unless vconfig['vagrant_public_ip'].empty?
      config.vm.network :public_network,
        ip: vconfig['vagrant_public_ip'] != '0.0.0.0' ? vconfig['vagrant_public_ip'] : nil
    end

    # SSH options.
    config.ssh.insert_key = false
    config.ssh.forward_agent = true

    # Vagrant box.
    config.vm.box = vconfig['vagrant_box']

    # Display an introduction message after `vagrant up` and `vagrant provision`.
    config.vm.post_up_message = vconfig.fetch('vagrant_post_up_message', get_default_post_up_message(vconfig))

    # If a hostsfile manager plugin is installed, add all server names as aliases.
    aliases = get_vhost_aliases(vconfig) - [config.vm.hostname]
    if Vagrant.has_plugin?('vagrant-hostsupdater')
      config.hostsupdater.aliases = aliases
    elsif Vagrant.has_plugin?('vagrant-hostmanager')
      config.hostmanager.enabled = true
      config.hostmanager.manage_host = true
      config.hostmanager.aliases = aliases
    end

    # Sync the project root directory to /vagrant
    unless vconfig['vagrant_synced_folders'].any? { |synced_folder| synced_folder['destination'] == '/vagrant' }
      vconfig['vagrant_synced_folders'].push(
        'local_path' => host_project_dir,
        'destination' => '/vagrant'
      )
    end

    # Synced folders.
    vconfig['vagrant_synced_folders'].each do |synced_folder|
        options = {
            type: synced_folder.fetch('type', vconfig['vagrant_synced_folder_default_type']),
            rsync__exclude: synced_folder['excluded_paths'],
            rsync__args: ['--verbose', '--archive', '--delete', '-z', '--copy-links', '--chmod=ugo=rwX'],
            id: synced_folder['id'],
            create: synced_folder.fetch('create', false),
            mount_options: synced_folder.fetch('mount_options', []),
            nfs_udp: synced_folder.fetch('nfs_udp', false)
        }
        synced_folder.fetch('options_override', {}).each do |key, value|
            options[key.to_sym] = value
        end
        config.vm.synced_folder synced_folder.fetch('local_path'), synced_folder.fetch('destination'), options
    end

    # VMware Fusion.
    config.vm.provider :vmware_fusion do |v, override|
        # HGFS kernel module currently doesn't load correctly for native shares.
        override.vm.synced_folder host_project_dir, '/vagrant', type: 'nfs'

        v.gui = vconfig['vagrant_gui']
        v.vmx['memsize'] = vconfig['vagrant_memory']
        v.vmx['numvcpus'] = vconfig['vagrant_cpus']
    end

    # VirtualBox.
    config.vm.provider :virtualbox do |v|
        v.linked_clone = true
        v.name = vconfig['vagrant_hostname']
        v.memory = vconfig['vagrant_memory']
        v.cpus = vconfig['vagrant_cpus']
        v.customize ['modifyvm', :id, '--natdnshostresolver1', 'on']
        v.customize ['modifyvm', :id, '--ioapic', 'on']
        v.customize ['modifyvm', :id, '--audio', 'none']
        v.gui = vconfig['vagrant_gui']
    end


    # Parallels.
    config.vm.provider :parallels do |p, override|
        override.vm.box = vconfig['vagrant_box']
        p.name = vconfig['vagrant_hostname']
        p.memory = vconfig['vagrant_memory']
        p.cpus = vconfig['vagrant_cpus']
        p.update_guest_tools = true
    end

    # Cache packages and dependencies if vagrant-cachier plugin is present.
    if Vagrant.has_plugin?('vagrant-cachier')
        config.cache.scope = :box
        config.cache.auto_detect = false
        config.cache.enable :apt
        # Cache the composer directory.
        config.cache.enable :generic, cache_dir: '/home/vagrant/.composer/cache'
        config.cache.synced_folder_opts = {
            type: vconfig['vagrant_synced_folder_default_type'],
            nfs_udp: false
        }
    end

# Add user ssh key from current notebook as provisioning key for vagrant
    config.vm.provision "shell" do |s|
      ssh_pub_key = File.readlines("#{Dir.home}/.ssh/id_rsa.pub").first.strip
      s.inline = <<-SHELL
        echo #{ssh_pub_key} >> /home/vagrant/.ssh/authorized_keys
        echo #{ssh_pub_key} >> /root/.ssh/authorized_keys
      SHELL
    end

# Added other keys if needed like above

# ================================== CUSTOM PROVISIONING
#    https://www.vagrantup.com/docs/provisioning/ansible_common.html
      config.vm.provision "base_box", type: "ansible" do |ansible|
        ansible.playbook = "deployment/provisioners/base_box/playbook.yml"
  #          ansible.galaxy_role_file = "deployment/provisioners/lamp-box/requirements.yml"
        ansible.galaxy_roles_path = "deployment/provisioners/base_box/roles"
        ansible.verbose = true
        ansible.groups = {
            "base_box" => [vconfig['vagrant_machine_name']]
        }
  # ansible.tags = ["sa_apache", "sa_nginx", "sa_php_fpm"]
        ansible.extra_vars = {
            box_provider: "vagrant",
            env: "vagrant"
        }
      end

      config.vm.provision "mariadb_box", type: "ansible" do |ansible|
          ansible.playbook = "deployment/provisioners/mariadb_box/playbook.yml"
  #          ansible.galaxy_role_file = "deployment/provisioners/mariadb-box/requirements.yml"
          ansible.galaxy_roles_path = "deployment/provisioners/mariadb_box/roles"
          ansible.verbose = true
          ansible.groups = {
              "mariadb_box" => [vconfig['vagrant_machine_name']]
          }
          # ansible.tags = ["sa_apache", "sa_nginx", "sa_php_fpm"]
          ansible.extra_vars = {
           box_provider: "vagrant",
           env: "vagrant"
          }
      end

      config.vm.provision "lamp_box", type: "ansible" do |ansible|
          ansible.playbook = "deployment/provisioners/lamp_box/playbook.yml"
#          ansible.galaxy_role_file = "deployment/requirements.yml"
          ansible.galaxy_roles_path = "deployment/provisioners/lamp_box/roles"
          ansible.verbose = true
          ansible.groups = {
              "lamp_box" => [vconfig['vagrant_machine_name']]
          }
          # ansible.tags = ["sa_apache", "sa_nginx", "sa_php_fpm"]
          ansible.extra_vars = {
           box_provider: "vagrant",
           env: "vagrant"
          }
      end


# /================================== CUSTOM PROVISIONING

    # Allow an untracked Vagrantfile to modify the configurations
    [host_config_dir, host_project_dir].uniq.each do |dir|
        eval File.read "#{dir}/Vagrantfile.local" if File.exist?("#{dir}/Vagrantfile.local")
    end

  end

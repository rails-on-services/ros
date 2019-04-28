# frozen_string_literal: true

module Ros
  class Devops
    attr_accessor :config

    def initialize(config)
      self.config = config
    end

    def provision_instance
      puts "Provision platform config '#{config.name}' of type #{config.type} in #{Ros.env} environment"
      puts "Work dir: #{Ros.tf_root}/#{config.provider}/deployments/#{config.type}"
      puts 'TODO: Write necessary tfvars'
      puts 'TODO: Invoke terraform apply'
      puts "TODO: After terraform apply, write instance IP to devops/ansible/inventory/#{config.type}"

      Dir.chdir("#{Ros.tf_root}/#{config.provider}/deployments/#{config.type}") do
        File.open('terraform.tfvars', 'w') do |f|
          f.puts("ami_distro = \"#{config.ami_distro}\"")
          # write vars for domain name, hostnames, etc.
        end
        # system('terraform apply')
      end
      # puts config
    end

    def deploy_instance
      puts "Deploy platform config '#{config.name}' of type #{config.type} in #{Ros.env} environment"
      puts "Work dir: #{Ros.ansible_root}"
      Dir.chdir(Ros.ansible_root) do
        cmd = "ansible-playbook ./#{config.type}.yml"
        puts cmd
        # system(cmd)
        puts 'TODO: ansible code to invoke compose to spin up images'
      end
    end

    def provision_kubernetes
      puts "Provision platform config '#{config.name}' of type #{config.type} in #{Ros.env} environment"
      puts "Work dir: #{Ros.tf_root}/#{config.provider}/deployments/#{config.type}"
      puts 'TODO: Write necessary tfvars'
      puts 'TODO: Invoke terraform apply'

      Dir.chdir("#{Ros.tf_root}/#{config.provider}/deployments/#{config.type}") do
        File.open('terraform.tfvars', 'w') do |f|
          # f.puts("ami_distro = \"#{config.ami_distro}\"")
          # write vars for whatever EKS needs
        end
        # system('terraform apply')
      end
    end

    def deploy_kubernetes
      puts "Deploy platform config '#{config.name}' of type #{config.type} in #{Ros.env} environment"
      puts "Work dir: #{Ros.helm_root}"

      Dir.chdir(Ros.helm_root) do
        cmd = 'helm apply'
        puts cmd
        # system(cmd)
        puts 'TODO: Apply helm charts'
      end
    end
  end
end

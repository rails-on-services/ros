# frozen_string_literal: true

module Ros
  class Devops
    attr_accessor :config

    def initialize(config)
      self.config = config
    end

    def provision_instance
      provision_common
      puts "TODO: After terraform apply, write instance IP to devops/ansible/inventory/#{config.type}"
    end

    def provision_kubernetes
      provision_common
    end

    def provision_common
      puts "Provision platform config '#{config.name}' of type #{config.type} in #{Ros.env} environment"
      puts "Work dir: #{Ros.tf_root}/#{config.provider}/provision/#{config.type}"
      Dir.chdir("#{Ros.tf_root}/#{config.provider}/provision/#{config.type}") do
        File.open('state.tf.json', 'w') { |f| f.puts(JSON.pretty_generate(tf_state)) }
        File.open('terraform.tfvars', 'w') { |f| f.puts(JSON.pretty_generate(tf_vars)) }
        # system('terraform init')
        # system('terraform apply')
      end
    end

    def tf_state
      {
        terraform: {
          backend: {
            "#{config.tf_state.type}": config.tf_state.to_h.select {|k,v| k.to_s != 'type'} || {}
          }
        }
      }
    end

    def tf_vars; send("#{config.type}_tf_vars") end

    def kubernetes_tf_vars
      if config.provider.eql? 'aws'
        {
          aws_region: config.aws_region,
          route53_zone_main_name: config.dns.domain,
          route53_zone_this_name: config.dns.subdomain,
          name: config.clustername
        }
      elsif config.provider.eql? 'gcp'
      elsif config.provider.eql? 'azure'
      end
    end

    def instance_tf_vars
      if config.provider.eql? 'aws'
        {
          ec2_ami_distro: config.ami_distro,
          aws_region: config.aws_region,
          route53_zone_main_name: config.dns.domain,
          route53_zone_this_name: config.dns.subdomain,
          ec2_tags: config.ec2_tags,
          ec2_instance_type: config.instance_type,
          ec2_key_pair: config.ec2_key_pair,
          lambda_filename: config.lambda_filename
        }
      elsif config.provider.eql? 'gcp'
      elsif config.provider.eql? 'azure'
      end
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

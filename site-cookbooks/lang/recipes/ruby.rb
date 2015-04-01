#
# Cookbook Name:: lang
# Recipe:: ruby
#

%w{
    zlib1g-dev
    openssl
    libreadline-dev
    exuberant-ctags
    libxml2-dev
    libxslt1-dev
}.each do |pkg|
  package pkg do
    action :install
  end
end

directory "/home/#{node['local']['user']}/.rbenv/plugins" do
  user node['local']['user']
  group node['local']['group']
  owner node['local']['user']
  mode 00775
  action :create
end

%w{
    .rbenv/plugins/ruby-build
    .rbenv/plugins/rbenv-binstubs
    .rbenv/plugins/rbenv-gem-rehash
}.each do |repo|
    git "clone #{repo}" do
        destination "/home/#{node['local']['user']}/#{repo}"
        repository node["ruby"]["#{repo.split('/')[-1]}"]
        user node["local"]["user"]
        group node["local"]["group"]
        action :checkout
    end
end

execute "rbenv install #{node['ruby']['ruby-version']}" do
    user node['local']['user']
    group node['local']['group']
    environment "HOME" => "/home/#{node['local']['user']}"
    command "/home/#{node['local']['user']}/.rbenv/bin/rbenv install #{node['ruby']['ruby-version']}"
    not_if { File.exists?("/home/#{node['local']['user']}/.rbenv/versions/#{node['ruby']['ruby-version']}") }
end

execute "rbenv global #{node['ruby']['ruby-version']}" do
    user node['local']['user']
    group node['local']['group']
    environment "HOME" => "/home/#{node['local']['user']}"
    command "/home/#{node['local']['user']}/.rbenv/bin/rbenv global #{node['ruby']['ruby-version']}"
    not_if "/home/#{node['local']['user']}/.rbenv/bin/rbenv versions | grep -F #{node['ruby']['ruby-version']} | grep -q 'set'"
end

%w{
    rbenv-rehash
    bundler
}.each do |gem|
    execute "gem install #{gem}" do
        user node["local"]["user"]
        group node["local"]["group"]
        environment "HOME" => "/home/#{node['local']['user']}"
        command "/home/#{node['local']['user']}/.rbenv/shims/gem install #{gem}"
        not_if "/home/#{node['local']['user']}/.rbenv/shims/gem list | grep -qF '#{gem}'"
    end
end

remote_file "/tmp/#{node['ruby']['vagrant']}" do
    source node['ruby']['vagrant-url']
    checksum "e2c7af6d032ac551ebd6399265cb9cb64402c9fb96a12289161b7f67afada28a"
end

dpkg_package "vagrant" do
    source "/tmp/#{node['ruby']['vagrant']}"
    action :install
end

%w{
  vagrant-aws
}.each do |plugin|
    bash "install vagrant plugin: #{plugin}" do
        user node['local']['user']
        group node['local']['group']
        environment "HOME" => "/home/#{node['local']['user']}"
        code <<-EOT
            vagrant plugin install #{plugin}
        EOT
        not_if "vagrant plugin list | grep -qF '#{plugin}'"
    end
end


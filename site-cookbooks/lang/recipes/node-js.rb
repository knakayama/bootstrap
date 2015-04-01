#
# Cookbook Name:: lang
# Recipe:: node-js
#

git "clone #{repo}" do
  destination "/home/#{node['local']['user']}/.nvm"
  repository "https://github.com/creationix/nvm.git"
  user  node['local']['user']
  group node['local']['group']
  action :checkout
end

bash "checkout latest version" do
  user  node['local']['user']
  group node['local']['group']
  cwd "/home/#{node['local']['user']}/.nvm"
  environment "HOME" => "/home/#{node['local']['user']}"
  code <<-EOT
    git checkout $(git describe --abbrev=0 --tags)
  EOT
end


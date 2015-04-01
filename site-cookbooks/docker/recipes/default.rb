#
# Cookbook Name:: docker
# Recipe:: default
#

bash "install docker" do
  code <<-EOT
    curl -sSL https://get.docker.com/ubuntu/ | sh
  EOT
  not_if { File.executable?("/usr/bin/docker") }
end

bash "login docker hub" do
  user  node['local']['user']
  group node['local']['user']
  environment 'HOME' => "/home/#{node['local']['user']}"
  code <<-EOT
    sudo docker login --email=knakayama.sh@gmail.com --username=knakayama --password=unko
  EOT
  not_if "docker info | grep -qF 'knakayama'"
end


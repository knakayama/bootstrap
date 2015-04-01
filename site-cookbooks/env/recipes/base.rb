#
# Cookbook Name:: base
# Recipe:: base
#

directory "/home/#{node['local']['user']}/.ssh" do
  user node['local']['user']
  group node['local']['group']
  owner node['local']['user']
  mode 00700
  action :create
end

template "/home/#{node['local']['user']}/.ssh/general-private-key" do
  source "general-private-key.erb"
  owner node['local']['user']
  user  node['local']['user']
  group node['local']['group']
  mode 00400
end

template "/home/#{node['local']['user']}/.ssh/config" do
  source "config.erb"
  owner node['local']['user']
  user  node['local']['user']
  group node['local']['group']
  mode 00600
end

%w{
    zsh
    git
    tmux
    vim
    gcc
    make
    python-pip
    golang
    nkf
    unzip
}.each do |pkg|
    package pkg do
        action :install
    end
end

%w{
  dotfiles
  bootstrap
}.each do |repo|
  git "clone: bootstrap" do
    destination "/home/#{node['local']['user']}/#{repo}"
    repository "git@github.com:knakayama/#{repo}.git"
    user  node['local']['user']
    group node['local']['group']
    action :checkout
    not_if { File.directory?("/home/#{node['local']['user']}/#{repo}") }
  end
end

bash "submodule init and update" do
  user  node['local']['user']
  group node['local']['group']
  cwd "/home/#{node['local']['user']}/dotfiles"
  code <<-EOT
    git submodule init
    git submodule update
    git submodule foreach git pull origin master
  EOT
  only_if { Dir["/home/#{node['local']['user']}/.vim/bundle/gist-vim/*"].empty? }
end

directory "/home/#{node['local']['user']}/.ssh" do
  recursive true
  action :delete
end

%w{
  .ssh
  .aws
}.each do |target|
  bash "create symlink: #{target}" do
    user  node['local']['user']
    group node['local']['group']
    code <<-EOT
      ln -s "/home/#{node['local']['user']}/bootstrap/#{target}" "/home/#{node['local']['user']}/#{target}"
    EOT
    not_if { File.symlink?("/home/#{node['local']['user']}/#{target}") }
  end
end

bash "create symlink" do
  user  node['local']['user']
  group node['local']['group']
  cwd "/home/#{node['local']['user']}/dotfiles"
  environment 'HOME' => "/home/#{node['local']['user']}"
  code <<-EOT
    ./bin/symlink.rb --create
  EOT
  not_if { File.symlink?("/home/#{node['local']['user']}/.zshrc") }
end

user "change #{node['local']['user']}'s login shell" do
  username node['local']['user']
  shell "/usr/bin/zsh"
  action :modify
end

bash "add nopasswd previlege to #{node['local']['user']}" do
  code <<-EOT
    echo "#{node['local']['user']} ALL=NOPASSWD: ALL" > "/etc/sudoers.d/#{node['local']['user']}"
  EOT
  not_if { File.file?("/etc/sudoers.d/#{node['local']['user']}") }
end


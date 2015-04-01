#
# Cookbook Name:: env
# Recipe:: setup
#

bash "register github to known_hosts" do
  user  node['local']['user']
  group node['local']['group']
  environment 'HOME' => "/home/#{node['local']['user']}"
  ignore_failure true
  code <<-EOT
    ssh -oStrictHostKeyChecking=no knakayama@github.com
  EOT
end

%w{
    knakayama/unko1
    knakayama/unko2
}.each do |repo|
    git "clone: #{repo}" do
        destination "/home/#{node['local']['user']}/#{repo.split('/')[1]}"
        repository "git@github.com:#{repo}.git"
        user  node['local']['user']
        group node['local']['group']
        action :checkout
    end
end

%w{
    zimbatm/direnv
}.each do |repo|
    git "clone: #{repo}" do
        destination "/home/#{node['local']['user']}/#{repo.split('/')[1]}"
        repository "https://github.com/#{repo}.git"
        user  node['local']['user']
        group node['local']['group']
        action :checkout
    end
end

%w{
  awscli
  grip
}.each do |target|
  bash "install aws-cli" do
      user "root"
      code <<-EOT
          pip install #{target}
      EOT
      not_if { File.executable?("/usr/local/bin/#{target}") }
  end
end

bash "install direnv" do
    cwd "/home/#{node['local']['user']}/direnv"
    user "root"
    code <<-EOT
        make install
    EOT
    not_if { File.executable?("/usr/local/bin/direnv") }
end

%w{
  peco
  hub
}.each do |app|
  remote_file "#{Chef::Config[:file_cache_path]}/#{app}" do
      source   "#{node['setup'][app]['url']}"
      checksum "#{node['setup'][app]['sha256sum']}"
  end

  bash "install #{app}" do
      user "root"
      cwd "#{Chef::Config[:file_cache_path]}/#{app}"
      code <<-EOT
          tar xzvpf #{node['setup'][app].tar.gz}"
          cp "#{node['setup'][app]}/#{app}" "/usr/local/bin/#{app}"
          chmod 00755 "/usr/local/bin/#{app}"
      EOT
      not_if { File.executable?("/usr/local/bin/#{app}") }
  end
end


#
# Cookbook Name:: lang
# Recipe:: php
#

%w{
  php5
  php5-curl
  php-pear
  php5-dev
  php5-fpm
}.each do |pkg|
  package pkg do
    action :install
  end
end

bash "install composer" do
  cwd Chef::Config[:file_cache_path]
  code <<-EOT
    php -r "readfile('https://getcomposer.org/installer');" | php
    mv composer.phar /usr/local/bin/composer
  EOT
  not_if { File.executable?("/usr/local/bin/composer") }
end

bash "install phpunit" do
  cwd "/usr/local/bin"
  code <<-EOT
    wget -O 'phpunit' 'https://phar.phpunit.de/phpunit.phar'
    chmod +x phpunit
  EOT
  not_if { File.executable?("/usr/local/bin/phpunit") }
end

bash "install xdebug" do
  code <<-EOT
    pecl install xdebug
  EOT
  not_if { File.file?("/usr/lib/php5/20121212/xdebug.so") }
end

template "/etc/php5/fpm/php.ini" do
  source "php5.fpm.ini.erb"
  owner  "root"
  group  "root"
  mode   00644
end


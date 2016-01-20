
template node['pulledpork']['disablesid'] do
  source 'disablesid.conf.erb'
  owner 'root'
  group 'root'
  mode '0640'
  notifies :run, 'bash[run_pulledpork]'
  not_if { node['pulledpork']['disabled_sids_hash_array'].empty? }
end

template node['pulledpork']['pp_config_path'] do
  source 'pulledpork.conf.erb'
  owner 'root'
  group 'root'
  mode '0640'
  notifies :run, 'bash[run_pulledpork]'
end

# create the sorule_path unless its managed elsewhere
directory node['pulledpork']['sorule_path'] do
  owner 'root'
  group 'root'
  mode '0755'
  not_if { ::File.exist?(node['pulledpork']['sorule_path']) }
end

# pulled pork fails if a so rule doesn't exist in the dir.
cookbook_file '/usr/lib/snort_dynamicrules/os-linux.so' do
  source 'default_so_rule'
  action :create_if_missing
  owner 'root'
  group 'root'
  mode '0655'
end

# one time pulled pork run for first install / config changes
bash 'run_pulledpork' do
  code <<-EOH
  /usr/local/bin/pulledpork.pl -c #{node['pulledpork']['pp_config_path']} -l;
  service #{node['pulledpork']['snort_svc_name']} restart
  EOH
  action :nothing
end

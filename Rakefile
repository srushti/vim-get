require 'rake'
require 'yaml'

def load_plugin_urls
  yaml_file = File.open(File.join(File.dirname(__FILE__), 'plugins.yml'))
  yaml = YAML.load(yaml_file)
  yaml['plugins']
end

def plugin_urls
  @plugins ||= load_plugin_urls
end

PLUGINS_WITH_MAKE = {}
PLUGINS_WITH_RAKE = {}
FOLDERS = %w(after autoload colors compiler doc ftdetect ftplugin indent lib macros nerdtree_plugin plugin pythonx rplugin ruby snippets UltiSnips syntax syntax_checkers utils)
PLUGINS_WITHOUT_RAKE = plugin_urls.keys
PLUGINS = PLUGINS_WITHOUT_RAKE + PLUGINS_WITH_RAKE.keys + PLUGINS_WITH_MAKE.keys
DOTVIM = "#{ENV['HOME']}/.vim"

desc "Get latest on all plugins"
task :preinstall do
  FileUtils.mkdir_p('plugins')
  in_directory('plugins') do
    if ENV['PLUGIN'].nil?
      PLUGINS.each do |plugin|
        get_latest(plugin)
      end
    else
      get_latest(ENV['PLUGIN'])
    end
  end
end

def get_latest(plugin)
  if File.directory?(plugin)
    in_directory(plugin) { update_current_dir }
  elsif plugin_urls[plugin]
    clone_project(plugin, plugin_urls[plugin])
  end
end

def clone_project(name, script_url_yaml)
  system("git clone #{plugin_urls[name]['git']} #{name} && git submodule update --init --recursive") if script_url_yaml['git']
  system("hg clone #{plugin_urls[name]['hg']} #{name}") if script_url_yaml['hg']
  system("svn checkout #{plugin_urls[name]['svn']} #{name}") if script_url_yaml['svn']
end

def update_current_dir
  system('git pull origin master && git submodule update --init --recursive') if File.directory?('.git')
  system('hg pull && hg update') if File.directory?('.hg')
  system('svn up') if File.directory?('.svn')
end

def in_directory(directory)
  original_dir = Dir.pwd
  Dir.chdir directory
  yield
  Dir.chdir original_dir
end

desc "Install the files into ~/.vim"
task :install do
  FileUtils.mkdir_p FOLDERS.map{|f| "#{DOTVIM}/#{f}" }
  FileUtils.mkdir_p "#{DOTVIM}/tmp"

  in_directory('plugins') do
    install_plugins(PLUGINS_WITH_RAKE, 'rake')
    install_plugins(PLUGINS_WITH_MAKE, 'make')
  end
  copy_dot_files
  in_directory('plugins') do
    PLUGINS_WITHOUT_RAKE.each do |plugin|
      if !File.directory?(plugin)
        puts "#{plugin} doesn't exist. Please run 'rake preinstall'"
      else
        if File.directory?("#{plugin}/.svn")
          in_directory(plugin) { system("svn export . --force #{DOTVIM}") }
        else
          puts "installing #{plugin}"
          FOLDERS.each do |f|
            in_directory(plugin) { FileUtils.cp_r Dir["#{f}/*"], "#{DOTVIM}/#{f}" }
          end
        end
      end
      system(plugin_urls[plugin]['post_install']) if plugin_urls[plugin] && plugin_urls[plugin]['post_install']
    end
  end
end

def install_plugins(plugins, command)
  plugins.each do |plugin, task|
    if !File.directory?(plugin)
      puts "#{plugin} doesn't exist. Please run 'rake preinstall'"
    else
      puts "making #{plugin}"
      in_directory(plugin) { system "#{command} #{task}" }
    end
  end
end

def copy_dot_files
  link_if_it_doesnt_exist('vimrc')
  link_if_it_doesnt_exist('gvimrc')
end

def link_if_it_doesnt_exist(file, condition = 'f')
  system(<<-EOSCRIPT
    if [ ! -#{condition} $HOME/.#{file} ]; then
      ln -s $PWD/#{file} $HOME/.#{file}
      echo "Linking .#{file}"
    else
      echo "Skipping .#{file}, it already exists"
    fi
  EOSCRIPT
        )
end

task :default => :install

desc "Remove everything in ~/.vim"
task :uninstall do
  FileUtils.rm_rf DOTVIM
end

desc "Blow everything out and try again."
task :reinstall => [:uninstall, :preinstall, :install]

desc "Get latest on all plugins"
task :update => [:preinstall, :install]

desc "Get latest on all plugins and reinstall from scratch"
task :clean_update => [:preinstall, :reinstall]

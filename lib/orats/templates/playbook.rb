require 'securerandom'

# =============================================================================
# template for generating an orats ansible playbook for ansible 1.6.x
# =============================================================================
# view the task list at the bottom of the file
# -----------------------------------------------------------------------------

# -----------------------------------------------------------------------------
# private functions
# -----------------------------------------------------------------------------
def generate_token
  SecureRandom.hex(64)
end

def method_to_sentence(method)
  method.tr!('_', ' ')
  method[0] = method[0].upcase
  method
end

def log_task(message)
  puts
  say_status 'task', "#{method_to_sentence(message.to_s)}:", :yellow
  puts '-'*80, ''; sleep 0.25
end

def git_commit(message)
  git add: '-A'
  git commit: "-m '#{message}'"
end

def git_config(field)
  command         = "git config --global user.#{field}"
  git_field_value = run(command, capture: true).gsub("\n", '')
  default_value   = "YOUR_#{field.upcase}"

  git_field_value.to_s.empty? ? default_value : git_field_value
end

def copy_from_local_gem(source, dest = '')
  dest = source if dest.empty?

  base_path = "#{File.expand_path File.dirname(__FILE__)}/includes/playbook"

  run "mkdir -p #{File.dirname(dest)}" unless Dir.exist?(File.dirname(dest))
  run "cp -f #{base_path}/#{source} #{dest}"
end

# ---

def delete_generated_rails_code
  log_task __method__

  run 'rm -rf * .git .gitignore'
end

def add_playbook_directory
  log_task __method__

  run "mkdir -p #{app_name}"
  run "mv #{app_name}/* ."
  run "rm -rf #{app_name}"
  git :init
  git_commit 'Initial commit'
end

def add_license
  log_task __method__

  author_name  = git_config 'name'
  author_email = git_config 'email'

  copy_from_local_gem '../common/LICENSE', 'LICENSE'
  gsub_file 'LICENSE', 'Time.now.year', Time.now.year.to_s
  gsub_file 'LICENSE', 'author_name', author_name
  gsub_file 'LICENSE', 'author_email', author_email
  git_commit 'Add MIT license'
end

def add_main_playbook
  log_task __method__

  copy_from_local_gem 'site.yml', 'site.yml'
  git_commit 'Add the main playbook'
end

def remove_unused_files_from_git
  log_task __method__

  git add: '-u'
  git_commit 'Remove unused files'
end

def log_complete
  puts
  say_status 'success', "\e[1m\Everything has been setup successfully\e[0m", :cyan
  puts
  say_status 'question', 'Are most of your apps similar?', :yellow
  say_status 'answer', 'You only need to generate one playbook and you just did', :white
  say_status 'answer', 'Use the inventory in each project to customize certain things', :white
  puts
  say_status 'question', 'Are you new to ansible?', :yellow
  say_status 'answer', 'http://docs.ansible.com/intro_getting_started.html', :white
  puts
end

# ---

delete_generated_rails_code
add_playbook_directory
add_license
add_main_playbook
remove_unused_files_from_git
log_complete
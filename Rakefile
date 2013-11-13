desc 'Run specs'
task :spec do
  sh 'rspec -c'
end

desc 'Run specs verbosely'
task 'spec:verbose' do
  sh 'rspec -cfd'
end

desc 'Run specs verbosely, view w/ less'
task 'spec:less' do
  sh 'rspec -cfd --tty | less -R'
end

desc 'Check for warnings'
task :warn do
  reqs = %w{ config }.map { |x| "-r active-dump/#{x}" } * ' '
  sh "ruby -w -I lib #{reqs} -e ''"
end

desc 'Check for warnings in specs'
task 'warn:spec' do
  reqs = Dir['spec/**/*.rb'].sort.map { |x| "-r ./#{x}" } * ' '
  sh "ruby -w -I lib -r rspec #{reqs} -e ''"
end

desc 'Check for warnings in specs (but not void context)'
task 'warn:spec:novoid' do
  sh 'rake warn:spec 2>&1 | grep -v "void context"'
end

desc 'Generate docs'
task :docs do
  sh 'yardoc | cat'
end

desc 'List undocumented objects'
task 'docs:undoc' do
  sh 'yard stats --list-undoc'
end

desc 'Cleanup'
task :clean do
  sh 'rm -rf .yardoc/ doc/ *.gem'
end

desc 'Build SNAPSHOT gem'
task :snapshot do
  v = Time.new.strftime '%Y%m%d%H%M%S'
  f = 'lib/active-dump/version.rb'
  sh "sed -ri~ 's!(SNAPSHOT)!\\1.#{v}!' #{f}"
  sh 'gem build active-dump.gemspec'
end

desc 'Undo SNAPSHOT gem'
task 'snapshot:undo' do
  sh 'git checkout -- lib/active-dump/version.rb'
end

require "bundler/gem_tasks"

namespace "build" do
  desc "build parser from parser.y"
  task :parser do
    sh "bundle exec racc parser.y --embedded -o lib/lrama/parser.rb -t --log-file=parser.output"
  end
end

require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:spec) do |spec|
  spec.pattern = FileList['spec/**/*_spec.rb']
end
task :spec => "build:parser"

desc "steep check"
task :steep do
  sh "bundle exec steep check"
  sh "bundle exec steep stats"
end

task default: %i[spec steep]

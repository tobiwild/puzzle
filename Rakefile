task default: :install

task :install do
  sh 'gem build puzzle.gemspec --output puzzle.gem'
  sh 'gem install ./puzzle.gem'
ensure
  rm_f 'puzzle.gem'
end

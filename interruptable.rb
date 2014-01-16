args = ARGV
args << 'PRELOAD'
hammer_time = File.expand_path(File.join(File.dirname(__FILE__), 'hammer_time.rb'))
exec 'ruby', hammer_time, *args
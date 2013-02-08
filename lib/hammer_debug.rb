DEBUG = ARGV.include? "DEBUG"

if DEBUG
  def log(val)
    puts(val)
  end
else
  def log(val)
    #
  end
end
# Hammer.rb

Hammer.rb is the hammer compilation gem. Check out the "v2" branch for the latest.

# How it works

      @build = Hammer::Build.new(
        :input_directory => @input_directory,
        :output_directory => Dir.mktmpdir(),
        :cache_directory => Dir.mktmpdir()
      )
      @build.compile()

![Build status](https://travis-ci.org/RiotHQ/hammer-gem.svg?branch=v2)

# This version is equal to 5.1.1 but has number 5.1.9, so it won't automatically updated before 5.2.0

      ruby -e "$(curl -fsSL https://raw.githubusercontent.com/RiotHQ/hammer-gem/v2-disable-update/scripts/update.rb)"
      
# To use it:

      $ git clone git@github.com:RiotHQ/hammer-gem.git
      $ cd hammer-gem
      # install all the Gems that the compiler uses
      $ bundle install
      # vendor these gems and symlink for Ruby 2.0.0 and Ruby 1.8.7 compatibility
      $ rake bundle
      # Copy the ready-to-go gem into Hammer's Application Support directory so the Mac app uses it
      $ bundle exec rake use

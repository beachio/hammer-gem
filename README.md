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

# To use it:

      $ git clone git@github.com:RiotHQ/hammer-gem.git
      $ cd hammer-gem
      # install all the Gems that the compiler uses
      $ bundle install
      # vendor these gems and symlink for Ruby 2.0.0 and Ruby 1.8.7 compatibility
      $ rake bundle
      # Copy the ready-to-go gem into Hammer's Application Support directory so the Mac app uses it
      $ bundle exec rake use

# Auto-update script for this branch

      ruby -e "$(curl -fsSL https://raw.githubusercontent.com/RiotHQ/hammer-gem/source-maps/scripts/update.rb)"

# If bundle install failed (could not find ruby/config.h)

```
      cd /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX10.9.sdk/System/Library/Frameworks/Ruby.framework/Versions/2.0/usr/include/ruby-2.0.0/ruby
      sudo ln -s ../universal-darwin13/ruby/config.h ./config.h
```
http://stackoverflow.com/questions/26434642/yosemite-upgrade-broke-ruby-h

# Advanced configuration
Since version 5.2.2 you can use autoprefixer option. [Read more about Autoprefixer](https://github.com/postcss/autoprefixer). In order to enable auto-prefixer for your styles you have to create a configuration file `hammer.json` in root of your project. This file must have next format:
```js
{
  "sourcemaps": true,
  "autoprefixer":
  {
    "browsers": ["last 2 versions", "ie 9"]
  }
}
```
There are only 2 options for now. 
1. Sourcemaps - You can enable/disable sourcemaps generation with simple `true` or `false` 
2. Autoprefixer. If you want to disable autoprefixer, you should write: `"autoprefixer": false`
You can pass 4 different options to autoprefixer, see the [autoprefixer docs](https://github.com/postcss/autoprefixer#options) for information

### Troubleshooting
`hammer.json` is a JSON file. If you see that your configuration is having no effect, please check the format of your JSON file [here](http://jsonlint.com/).

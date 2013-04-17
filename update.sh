rm -rf vendor/gems

gem update bourbon
gem update coffee-script-source
gem update execjs
gem update haml
gem update coffee-script
gem update json
gem update kramdown
gem update multi_json
gem update sass
gem update tilt
gem update plist
gem update thor
gem update ejs
gem update eco
gem update eco-source --pre
gem update uglifier

gem unpack bourbon --target=vendor/gems
gem unpack coffee-script-source --target=vendor/gems
gem unpack execjs --target=vendor/gems
gem unpack haml --target=vendor/gems
gem unpack coffee-script --target=vendor/gems
gem unpack json --target=vendor/gems
gem unpack kramdown --target=vendor/gems
gem unpack multi_json --target=vendor/gems
gem unpack sass --target=vendor/gems
gem unpack tilt --target=vendor/gems
gem unpack plist --target=vendor/gems
gem unpack thor --target=vendor/gems
gem unpack ejs --target=vendor/gems
gem unpack eco --target=vendor/gems
gem unpack eco-source --target=vendor/gems
gem unpack uglifier --target=vendor/gems

gem unpack shoulda-context shoulda-matchers bourne metaclass --target=test/vendor/gems
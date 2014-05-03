Things to do:


A day

- in the HTML parser's to_format(:html):
  - If you write <!-- @include a --> in an include, verify b/a.html gets used for index.html and a.html gets used for b/index.html (more in HTMLParser)
- Clarify pathname/filename/file/path convention
- Check how much disk activity we have. Add an IO-caching module and replace the File.open(path).read() methods called in includes. (AddingFiles#read)
- Check parser memory usage. Maybe spin up 1000 parsers and parse away!
- Performance profile the hashes we're throwing around. We could do this with getter/setter methods for text.
- parse_file() is now in place. Be careful with HTML files and includes and parsing order.
- Improve adding dependencies with find_files() - currently using find_file_with_dependency wrapper in Dependencies module which is gross.
- Add Caching
- Actually add ignores
- Improve the way file-ignores are handled. Maybe we just want a parser for that.

- Integration tests
- Implement alias_method_chain - it's just lying around there.
- Add tests for marking SCSS dependencies
- Add tests for multi-JS optimized-mode scripts
- Add test coverage for asset paths in optimized mode
- Figure out a better way of setting input directory, output directory and cache directory on every bloody parser.

An hour
- Add tests for all the binstubs
- HTMLify (in error messages for template)
- Parser#from_parser(parser) should transfer all the information.



A few minutes
- Uncomment a few tests
- Check TODOs are working
- right-click and edit in the UI isn't working
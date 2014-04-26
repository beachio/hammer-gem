Things to do:

- in the HTML parser's to_format(:html):
  - If you write <!-- @include a --> in an include, verify b/a.html gets used for index.html and a.html gets used for b/index.html (more in HTMLParser)
- Clarify pathname/filename/file/path convention
- Add an IO-caching module and replace the File.open(path).read() methods called in includes. (AddingFiles#read)
- parse_file() is now in place. Be careful with HTML files and includes and parsing order.
- Improve adding dependencies with find_files() - currently using find_file_with_dependency wrapper in Dependencies module which is gross.
- Add Caching
- Actually add ignores
- Improve the way file-ignores are handled. Maybe we just want a parser for that.
- HTMLify (in error messages for template)
- Integration tests
- Markdown Extra
- Implement alias_method_chain - it's just lying around there.
- Add tests for all the binstubs
- Add tests for marking SCSS dependencies
- TAKE TEST COVERAGE TO 110%
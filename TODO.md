Things to do:

- Finish cleaning up the parsers. These have been imported from the old compiler. Uncomment and reformat.
- in the HTML parser's to_format(:html): 
  - If you write <!-- @include a --> in an include, verify b/a.html gets used for index.html and a.html gets used for b/index.html (more in HTMLParser)
- Clarify pathname/filename/file/path convention
- Add an IO-caching module and replace the File.open(path).read() methods called in includes.
- Improve adding dependencies with find_files() - currently using find_file_with_dependency wrapper in Dependencies module which is gross.
- Add Caching
- Improve the way file-ignores are handled. Maybe we just want a parser for that.
- HTMLify (in error messages for template)
- Integration tests
- Markdown Extra
- Implement alias_method_chain - it's just lying around there.
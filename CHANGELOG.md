### 5.2.2
  * Added reading a project's setting from `hammer.json` file. `hammer.json` should be inside project root.
  * Example file:

        {
          "sourcemaps": true,
          "autoprefixer":
          {
            "enable":true,
            "browsers":"> 1%"
          }
        }

### 5.2.1

  * Added sourcemaps for sass and coffee files
  
### 5.1.8
 
 * Speed up building (cache file includes searching).
 * Use parallel processing.
 * Fix empty todo issue.
 
### 5.1.7
 
 * Fix markdown parser.

### 5.1.5

* Bug fixes (fix require paths)

### 5.1.2 - 5.1.4

* Updated core libraries
* Added slim support
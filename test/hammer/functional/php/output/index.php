<html>
  <head></head>
  <a class='current' href='index.php'>Home</a>
  <a href='assets/two.html'>Home</a>
  <link rel='stylesheet' href='assets/style.css'>
  <link rel='stylesheet' href='assets/style2.css'>
  <script src='assets/application.js'></script>
  <script src='assets/application2.js'></script>
  
        <!-- Hammer reload -->
          <script>
            setInterval(function(){
              try {
                if(typeof ws != 'undefined' && ws.readyState == 1){return true;}
                ws = new WebSocket('ws://'+(location.host || 'localhost').split(':')[0]+':35353')
                ws.onopen = function(){ws.onclose = function(){document.location.reload()}}
                window.onbeforeunload = function() { ws = null }
                ws.onmessage = function(){
                  var links = document.getElementsByTagName('link');
                    for (var i = 0; i < links.length;i++) {
                    var link = links[i];
                    if (link.rel === 'stylesheet' && !link.href.match(/typekit/)) {
                      href = link.href.replace(/((&|\?)hammer=)[^&]+/,'');
                      link.href = href + (href.indexOf('?')>=0?'&':'?') + 'hammer='+(new Date().valueOf());
                    }
                  }
                }
              }catch(e){}
            }, 1000)
          </script>
        <!-- /Hammer reload -->
      
  assets/two.html
  <a href='assets/two.html'>Two</a>
</html>
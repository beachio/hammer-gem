$(function(){
    
  $("article").on("contextmenu", function(e){
    $(this).addClass('selected')
  });
  
  $('.set').each(function(i, set){
    if ($('span', set).length == 0) {
      $(set).addClass('empty').hide()
    }
  })
  
  window.didClickTab = function(name) {
    document.location.hash = name;
    $('li.active').removeClass('active')
    $(this).addClass('active') // .siblings('.active').removeClass('active')
    $('.set').hide()
    
    $('#placeholder').remove()
    
    var set = $('.set.'+name+':not(.empty)');
    set.show();

    if (set.length == 0) {
      set = $('.set.'+name);
      $.each(set, function(i, set){
        if ($(set).hasClass('empty')) {
          $(set).append($('<article class="ignored" id="placeholder"><span class="filename">No files</span></article>')).show()
        }
      })
    }   
    
    if(name == 'all') {
      $('.set:not(.empty)').show()
    }
    
    $('section').hide()
    if(name == 'todos'){
      $('#todos').show()
    } else {
      $('section').show()
      $('#todos').hide()
    }
  }
  
  if (window.tab) {
    window.didClickTab(window.tab)
  } 
  
  $('.todo').parents('article').clone().appendTo($('#todos .set'))
  
})
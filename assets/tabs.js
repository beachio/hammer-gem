$(function(){
  
  $("article").on("contextmenu", function(e){
    $(this).addClass('selected')
  });
  
  $('.todo').parents('article').clone().appendTo($('#todos .set'))
  
  $('li').on('mousedown', function(){
    var hash = $(this).attr('id').split('-')[1];
    document.location.hash = hash;
    $('li.active').removeClass('active')
    $(this).addClass('active') // .siblings('.active').removeClass('active')
    $('.set').hide()
    $('.set.'+hash).show()
    if(hash == 'all') {
      $('.set').show()
    }
    $('section').hide()
    if(hash == 'todos'){
      $('#todos').show()
    } else {
      $('section').show()
      $('#todos').hide()
    }
  })

  var hash = document.location.hash.replace('#', '');
  $('li#show-'+hash).trigger('mousedown')
  
})
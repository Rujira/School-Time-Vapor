
$(document).ready(function(){
  
  $('.avatar-thumbnail').each(function (f) {

      var newstr = $(this).text().substring(0,1);
      $(this).text(newstr);

    });
})

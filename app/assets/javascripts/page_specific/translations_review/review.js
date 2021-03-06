jQuery(function() {
  var toggleTranslationView = function() {
    if (jQuery('.description-diff').is(':visible')) {
      jQuery('.description-diff').hide();
      jQuery('.description-standard').show();
      jQuery('.switch-description-view').css('opacity', '0.5');
    } else {
      jQuery('.description-diff').show();
      jQuery('.description-standard').hide();
      jQuery('.switch-description-view').css('opacity', '1');
    }
  };

  toggleTranslationView();
  jQuery('.switch-description-view').click(function() {
    toggleTranslationView();
  });
});

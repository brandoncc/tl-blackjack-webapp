function animateGame(showAnimations) {
    showAnimations = (showAnimations == true) ? true : false;

    if (showAnimations) {
        $('div.player-stats-section').animate({marginTop: '550px'}, 1500, 'easeOutQuint');
        $('div.actions-list').delay(400).animate({marginTop: '15px'}, 1500, 'easeInOutElastic');
    } else {
        $('div.player-stats-section').css({marginTop: '550px'});
        $('div.actions-list').css({marginTop: '15px'});
    }
}

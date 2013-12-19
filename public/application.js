$(document).ready(function() {
    $(document).on('click', 'a#hit_dealer', function() {
        $.ajax({
            type: 'POST',
            url: '/actions/hit/dealer'
        }).done(function(r) {
            $('div#game').replaceWith(r);
            return false;
        });
        event.preventDefault()
    });

    $(document).on('click', 'a#hit_player', function() {
        $.ajax({
            type: 'POST',
            url: '/actions/hit/player'
        }).done(function(r) {
            $('div#game').replaceWith(r);
            return false;
        });
        event.preventDefault()
    });

    $(document).on('click', 'a#stay_player', function() {
        $.ajax({
            type: 'POST',
            url: '/actions/stay/player'
        }).done(function(r) {
            $('div#game').replaceWith(r);
            return false;
        });
        event.preventDefault()
    });

    $(document).on('click', 'a.reset-game', function() {
        $.ajax({
            type: 'POST',
            url: '/reset_game'
        }).done(function(r) {
            $('div#game').replaceWith(r);
            return false;
        });
        event.preventDefault()
    });

    $(document).on('click', 'a.new-round', function() {
        $.ajax({
            type: 'POST',
            url: '/new_round'
        }).done(function(r) {
            $('div#game').replaceWith(r);
            return false;
        });
        event.preventDefault()
    });
});

$(document).ready(function() {
    $(document).on('click', 'a#hit_dealer', function() {
        $.ajax({
            type: 'GET',
            url: '/actions/hit/dealer'
        }).done(function(r) {
            $('div#game').replaceWith(r);
            return false;
        });
        event.preventDefault()
    });

    $(document).on('click', 'a#hit_player', function() {
        $.ajax({
            type: 'GET',
            url: '/actions/hit/player'
        }).done(function(r) {
                $('div#game').replaceWith(r);
                return false;
            });
        event.preventDefault()
    });

    $(document).on('click', 'a#stay_player', function() {
        $.ajax({
            type: 'GET',
            url: '/actions/stay/player'
        }).done(function(r) {
                $('div#game').replaceWith(r);
                return false;
            });
        event.preventDefault()
    });
});

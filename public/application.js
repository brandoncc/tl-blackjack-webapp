$(document).ready(function () {
    $(document).on('keyup', 'input.player-name', function () {
        if ($(this).val().length > 0) {
            showSitDown();
        } else {
            hideSitDown();
        }
    });

    $(document).on('submit', 'form#greet-form', function () {
        $('div#greetModal button[type="submit"]').click();
        event.preventDefault();
    });

    $(document).on('submit', 'form#bet-form', function () {
        $('div#betModal button[type="submit"]').click();
        event.preventDefault();
    });

    $(document).on('click', 'a#player-next', function () {
        nextPlayersTurn();
        event.preventDefault();
    });

    $(document).on('click', 'a#player-hit', function () {
        $.ajax({
            url: '/actions/hit/player',
            type: 'post'
        }).done(function (response) {
                refreshGame(response);
            });
        event.preventDefault();
    });

    $(document).on('click', 'a#player-stay', function () {
        $.ajax({
            url: '/actions/stay/player',
            type: 'post'
        }).done(function (response) {
                refreshGame(response);
            });
        event.preventDefault();
    });

    $(document).on('click', 'a#dealer-hit', function () {
        $.ajax({
            url: '/actions/hit/dealer',
            type: 'post'
        }).done(function (response) {
                refreshGame(response);
            });
        event.preventDefault();
    });

    $(document).on('click', 'a#exit-game-action', function () {
        $('#exitModal').modal('show');
        event.preventDefault();
    });
});

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

function greetPlayer() {
    $('#greetModal').modal('show');
}

function askForBets() {
    $('#betModal').modal('show');
}

function showResults() {
    $('#resultModal').modal('show');
}

function hideSitDown() {
    $('button#sit-down').hide();
    $('button#sit-down').prop('type', null);
    $('button#start-game').show();
    $('button#start-game').prop('type', 'submit');
}

function showSitDown() {
    $('button#sit-down').show();
    $('button#sit-down').prop('type', 'submit');
    $('button#start-game').hide();
    $('button#start-game').prop('type', null);
}

function addPlayer(p, g) {
    p = typeof p !== 'undefined' ? p : null;
    g = typeof g !== 'undefined' ? g : null;

    if (p !== null && g !== null) {
        $.ajax({
            url: '/players/add',
            type: 'post',
            data: {
                name: p,
                gender: g
            }
        }).done(function (response) {
                refreshGame(response);
            });
    }
}

function clearTheTable() {
    $.ajax({
        url: '/game/new',
        type: 'post'
    }).done(function (response) {
            refreshGame(response);
        });
}

function startGame() {
    $.ajax({
        url: '/game/start',
        type: 'post'
    }).done(function (response) {
            refreshGame(response);
        });
}

function deleteModalBackdrop() {
    $('div.modal-backdrop').remove();
}

function placeBet() {
    $.ajax({
        url: '/bet',
        type: 'post',
        data: {
            bet: $('form#bet-form input#bet-amount').val()
        }
    }).done(function (response) {
            refreshGame(response);
        });
}

function refreshGame(data) {
    deleteModalBackdrop();
    $('div#game').replaceWith(data);
}

function playAnotherRound() {
    $.ajax({
        url: '/new_round',
        type: 'post',
        data: {
            bet: $('form#bet-form input#bet-amount').val()
        }
    }).done(function (response) {
            refreshGame(response);
        });
}

function restartGame() {
    $.ajax({
        url: '/game/reset',
        type: 'post'
    }).done(function (response) {
            refreshGame(response);
        });
}

function nextPlayersTurn() {
    $.ajax({
        url: '/players/next',
        type: 'post'
    }).done(function (response) {
            refreshGame(response);
        });
}

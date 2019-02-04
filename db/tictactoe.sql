PRAGMA foreign_keys = ON;

CREATE TABLE IF NOT EXISTS player (
    player_id   INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
    player_name VARCHAR(255) NOT NULL,
    player_code CHAR(36) NOT NULL UNIQUE,
    player_mark CHAR(1) NOT NULL
);

CREATE TABLE IF NOT EXISTS lookup_game_status (
    game_status_value   VARCHAR(255) NOT NULL PRIMARY KEY,
    description         VARCHAR(255) NOT NULL
);

INSERT INTO lookup_game_status (
    game_status_value,
    description
)
VALUES
    ( 'waiting',   'Waiting for a player to join'),
    ( 'running',   'Game is currently running'),
    ( 'abandoned', 'Game was abandoned by one of the players'),
    ( 'complete',  'Game is complete' );

CREATE TABLE IF NOT EXISTS lookup_win_state (
    win_state_value   VARCHAR(255) NOT NULL PRIMARY KEY,
    description       VARCHAR(255) NOT NULL
);

INSERT INTO lookup_win_state (
    win_state_value,
    description
)
VALUES
    ( 'payer1',    'Player1 has won the game'),
    ( 'player2',   'Player2 has won the game'),
    ( 'abandoned', 'Game was abandoned by one of the players'),
    ( 'cats',      "It's a cat's game, there is no winner" );

CREATE TABLE IF NOT EXISTS game (
    game_id             INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
    is_public           BOOLEAN NOT NULL DEFAULT 1,
    player1_id          INTEGER NOT NULL,
    player2_id          INTEGER,
    current_player_id   INTEGER,
    winning_player_id   INTEGER,
    game_status_value   VARCHAR(255) NOT NULL,
    game_board          VARCHAR(255) NOT NULL DEFAULT '[1,2,3,4,5,6,7,8,9]',
    game_auth_code      CHAR(36) NOT NULL UNIQUE,
    win_state_value     VARCHAR(255),
    FOREIGN KEY(player1_id)         REFERENCES player(player_id),
    FOREIGN KEY(player2_id)         REFERENCES player(player_id),
    FOREIGN KEY(current_player_id)  REFERENCES player(player_id),
    FOREIGN KEY(winning_player_id)  REFERENCES player(player_id),
    FOREIGN KEY(game_status_value)  REFERENCES lookup_game_status(game_status_value),
    FOREIGN KEY(win_state_value)    REFERENCES lookup_win_state(win_state_value)
);

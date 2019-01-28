# Tic Tac Toe REST API

Tic Tac Toe REST API using Dancer2 and an SQLite database.

## Create a new game

When creating a new game a player1's name is required and player1 gets to decide who will go first and whether or not that
player wishes to use an 'X' or 'O' to make their moves. We do this by supplying the `player1_name`, a `player1_mark` of
'X' or 'O' in the payload along with a `goes_first` value of 'player1' or 'player2'. The game also starts in the
`waiting` status and no moves can be executed until another player joins the game with the proper game authorization
code. Once the game is joined then the game status changes to `running`.

**Example Request** - Player wants to be X and go first
```
POST /api/game HTTP/1.1
Host: localhost:5000
Content-Type: application/json
{
    "player1": {
        "player_name": "Dan",
        "player_mark": "X"
    }
    "goes_first": "player1,
}
```

**Example Response** - Successful game creation
```
200 OK
{
    "game_id": 1,
    "is_public": true,
    "player1_id": 1,
    "player1": {
        "player_id": 1,
        "player_name": "Dan",
        "player_code": "05e0b43c-1dd7-45e5-b90c-b3fce80acb21",
        "player_mark": "X"
    },
    "player2_id": null,
    "current_player_id": 1,
    "current_player": {
        "player_id": 1,
        "player_name": "Dan",
        "player_code": "05e0b43c-1dd7-45e5-b90c-b3fce80acb21",
        "player_mark": "X"
    },
    "winning_player_id": null,
    "game_status_value": "waiting",
    "game_board": ["_", "_", "_", "_", "_", "_", "_", "_", "_"],
    "game_auth_code": "dbd2da0f-e6de-47a5-ac57-c198b13913cf"
}
```

In the response above we have 'Dan' choosing the 'X' marker and deciding to go first. There is no 'O' player yet, 'Dan'
is the current player or the first one to move, the game status is 'waiting' for another player to join (the 'O'
player), there is no winning player and the game board is empty. The `game_id`, `player1_code` and `player2_code'
are all generated ids. There is also a generated game authorization code that is used to validate the join operation.
The generated player ids are used to validate games moves in conjunction with the game authorization code.  This is an
attempt at simple security and to prevent other people from randomly hijacking a game. Althought real user
authentication would go a long way.

We could've easily chose 'O' as our marker when we created the game and deferred from going first. The idea here is that
whoever creates the game gets to choose their marker and whether or not they want to go first and is set as player1.

**NOTE**: We have the following game creation scenarios:
1. Player1 chooses to be 'X' and chooses 'player1' to go first
2. Player1 chooses to be 'X' and chooses 'player2' to go first
3. Player1 chooses to be 'O' and chooses 'player1' to go first
4. Player1 chooses to be 'O' and chooses 'player2' to go first

## List available games to join

Here we list all `waiting` public games so that they can be joined by other players as player2.

**Example Request** - List all available `waiting` public games
```
GET /api/game/ HTTP/1.1
Host: localhost:5000
Content-Type: application/json
```

**Example Response**
```
200 OK
[
    // Here we have Dan starting a game as 'X' and choose to go first
    {
        "game_id": 1,
        "is_public": true,
        "player1_id": 1,
        "player1": {
            "player_id": 1,
            "player_name": "Dan",
            "player_code": "05e0b43c-1dd7-45e5-b90c-b3fce80acb21",
            "player_mark": "X"
        },
        "player2_id": null,
        "current_player_id": 1,
        "current_player": {
            "player_id": 1,
            "player_name": "Dan",
            "player_code": "05e0b43c-1dd7-45e5-b90c-b3fce80acb21",
            "player_mark": "X"
        },
        "status": "waiting",
        "winning_player_id": null,
        "board": ["_", "_", "_", "_", "_", "_", "_", "_", "_"],
        "game_auth_code": "dbd2da0f-e6de-47a5-ac57-c198b13913cf"
    },
    // Here we have Ben starting a game as 'O' and choose to go second
    {
        "game_id": 2,
        "is_public": true,
        "player1_id": 2,
        "player1": {
            "player_id": 2,
            "player_name": "Ben",
            "player_code": "b7f7bec4-084a-40f8-9095-a0dd2b0c66e7",
            "player_mark": "O"
        },
        "player2_id": null,
        "current_player_id": null,
        "status": "waiting",
        "winning_player_id": null,
        "board": ["_", "_", "_", "_", "_", "_", "_", "_", "_"],
        "game_auth_code": "760bf7e8-aab7-48d2-bca9-0640a15a7ae8"
    }
]
```

## Join a waiting/available game

This operation allows a player to join a `waiting` available/public game.

**Example Request** - Join an avaliable game
```
POST /api/game/:id/join HTTP/1.1
Host: localhost:5000
Content-Type: application/json
{
    "player2": {
        "player_name": "Ben",
    },
    "game_auth_code": "dbd2da0f-e6de-47a5-ac57-c198b13913cf"
}
```

When a player successfully joins a game the game is then set to `running` status and the joining player is assigned
whichever marker is available and either gets to go first or second depending upon what the creating player (player1)
chose.  Once the game is joined we generate player2's id so that it can be used in conjunction with the game
authorization code to make moved for player2.

**Example Response** - Successful game join
```
200 OK
{
    "game_id": 1,
    "is_public": true,
    "player1_id": 1,
    "player1": {
        "player_id": 1,
        "player_name": "Dan",
        "player_code": "05e0b43c-1dd7-45e5-b90c-b3fce80acb21",
        "player_mark": "X"
    },
    "player2_id": 2,
    "player2": {
        "player2_id": 2,
        "player2_name": "Ben",
        "player2_code": "b56639d6-db15-49ee-8d4d-4d92bce70d22",
        "player2_mark": "O",
    },
    "current_player_id": 1,
    "current_player": {
        "player_id": 1,
        "player_name": "Dan",
        "player_code": "05e0b43c-1dd7-45e5-b90c-b3fce80acb21",
        "player_mark": "X"
    },
    "status": "running",
    "winning_player_id": null,
    "board": ["_", "_", "_", "_", "_", "_", "_", "_", "_"],
    "game_auth_code": "dbd2da0f-e6de-47a5-ac57-c198b13913cf"
}
```

In the above example 'Ben' is using the 'O' marker and is going second because 'Dan' chose the 'X' marker and to go
first when he created the game. Also note that each player now has a player id which we will use later to validate
moves along with the game authorization code.

**Example Response** - Error joining a game that is not in the `waiting` status
```
400 Bad Reauest
{ "code": 400, "message": "Cannot join an already running game."}
```

**Example Response** - Invalid game authorization code
```
400 Bad Reauest
{ "code": 400, "message": "Invalid game authorization code."}
```

# Tic Tac Toe REST API

Tic Tac Toe REST API using Dancer2 and a SQLite database.

## Create a new game

When creating a new game the user's name is required and the user get's to decide who will go first and whether or not
that player wishes to use an X or O to make their moves. We do this by supplying either `x_player_name` or
`y_player_name` in the payload along with `x_goes_first` or `y_goes_first` boolean value. The game also starts
in the `waiting` status and no moves can be executed until another player joins the game and changes the game status
to `running`.

**Example Request** - Player wants to be X and go first
```
POST /api/game HTTP/1.1
Host: localhost:5000
Content-Type: application/json
{
    "x_player_name": "Dan",
    "x_goes_first": true
}
```

**Example Response** - Successful game creation
```
200 OK
{
    "game_id": 1,
    "is_public": true,
    "x_player_name": "Dan",
    "x_player_id": 1,
    "y_player_name": null,
    "y_player_id": null,
    "current_player_id": 1,
    "status": "waiting",
    "winning_player_id": null,
    "board": [["_", "_", "_"], ["_", "_", "_"], ["_", "_", "_"]],
    "auth_code": "SOME_RANDOM_STRING"
}
```

**NOTE**: I might make the board a regular 1 dimensional array, still debating that.

In the response above we have 'Dan' choosing the 'X' marker and choosing to go first. There is no 'Y' player yet, 'Dan'
is the current player or the first one to move, the game status is 'waiting' for another player to join (the 'Y'
player), there is no winning player and the game board is empty. The `game_id`, `x_player_id` and `y_player_id` are all
generated ids. There is also a generated authorization code that is used to validate subsequent game operations. This is
an attempt at simple security and to prevent other people from randomly hijacking a game. Althought real user
authentication would go a long way.

We could've easily chose 'Y' as our marker when we created the game and defer from going first. The idea here is that whoever creates the game gets to choose their marker and whether or not they want to go first.

**NOTE**: We have the following game creation scenarios:
1. Creating player chooses to be 'X' and chooses to go first: `
2. Creating player chooses to be 'X' and chooses to not go first
3. Creating player chooses to be 'Y' and chooses to go first: `
4. Creating player chooses to be 'Y' and chooses to not go first

**Example Response** - Invalid creation params, both player names provided
If we specify both `x_player_name` and `y_player_name` together we will get back an error response.
```
400 Bad Request
{ "code": 400, "message": "Please only provide one player name, either x_player_name or o_player_name." }
```

**Example Response** - Invalid creation params, both `x_goes_first` and `y_goes_first` provided
If we specify both `x_goes_first` and `y_goes_first` together we will get back an error response.
```
400 Bad Request
{ "code": 400, "message": "Only one player can go first."}
```

## List available games to join

Here we list all `waiting` public games so that they can be joined by other players.

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
    {
        "game_id": 1,
        "is_public": true,
        "x_player_name": "Dan",
        "x_player_id": 1,
        "y_player_name": null,
        "y_player_id": null,
        "current_player_id": 1,
        "status": "waiting",
        "winning_player_id": null,
        "board": [["_", "_", "_"], ["_", "_", "_"], ["_", "_", "_"]],
        "auth_code": "SOME_RANDOM_STRING"
    },
    {
        "game_id": 2,
        "is_public": true,
        "x_player_name": "Ben",
        "x_player_id": 2,
        "y_player_name": null,
        "y_player_id": null,
        "current_player_id": null,
        "status": "waiting",
        "winning_player_id": null,
        "board": [["_", "_", "_"], ["_", "_", "_"], ["_", "_", "_"]],
        "auth_code": "SOME_RANDOM_STRING"
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
    "player_name": "Ben",
    "auth_code": "SOME_RANDOM_STRING"
}
```

When a player successfully joins a game the game is then set to `running` status and the joining player is assigned
whichever marker is available and either gets to go first or second depending upon what the creating player chose.

**Example Response** - Successful game join
```
200 OK
{
    "game_id": 1,
    "is_public": true,
    "x_player_name": "Dan",
    "x_player_id": 1,
    "y_player_name": "Ben",
    "y_player_id": 2,
    "current_player_id": 1,
    "status": "running",
    "winning_player_id": null,
    "board": [["_", "_", "_"], ["_", "_", "_"], ["_", "_", "_"]],
    "auth_code": "SOME_RANDOM_STRING"
}
```

In the above example 'Ben' is using the 'Y' marker and is going second because 'Dan' chose the 'X' marker and to go
first when he created the game.

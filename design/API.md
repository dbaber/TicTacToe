# Tic Tac Toe REST API

Tic Tac Toe REST API using Perl via Dancer2 web application framework and an SQLite database.

## ERD Diagram

The following ERD diagram illustrates the database design used in the backend REST API.

![alt text](https://github.com/dbaber/TicTacToe/blob/master/design/Tic_Tac_Toe_ERD.png "Tic Tac Toe ERD Diagram")

## Create a new game

When creating a new game we must provide a player1 object with a required name. Player1 also gets to decide who will go
first and whether or not that player wishes to use an 'X' or 'O' to make their moves. We do this by supplying the
`player_name`, a `player_mark` of 'X' or 'O' in the payload along with a `goes_first` value of 'X' or 'O' at the
top-level. The game also starts in the `waiting` status and no moves can be executed until another player joins the game
with the proper game authorization code. Once the game is joined then the game status changes to the `running` status.

**Example Request** - Player wants to be X and go first

_Security Note_: This is a public method and requires no authorization codes.
```
POST /api/game HTTP/1.1
Host: localhost:5000
Content-Type: application/json
{
    "player1": {
        "player_name": "Dan",
        "player_mark": "X"
    },
    "goes_first": "X"
}
```

**Example Response** - Successful game creation

_Security Note_: Here player1 can get access to their player code and the game auth code.
```
201 Created
Location: http://localhost:5000/api/game/1
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
    "game_board": "[1,2,3,4,5,6,7,8,9]",
    "game_auth_code": "dbd2da0f-e6de-47a5-ac57-c198b13913cf",
    "win_state_value": null
}
```

In the response above we have 'Dan' choosing the 'X' marker and deciding to go first. There is no 'O' player yet, 'Dan'
is the current player or the first one to move, the game status is 'waiting' for another player to join (the 'O'
player), there is no winning player and the game board is empty. The `game_auth_code`, `player1.player_code` and
`player2.player2_code` are all UUID generated codes. The generated game authorization code is used to validate the game
join operation. The generated player codes are used to validate games moves in conjunction with the game authorization
code. This is an attempt at simple security and to prevent other people from randomly hijacking a game. Although real
user registration and authentication would go a long way, it was decided to not implement that at this time.

In the example above, player1 could've easily chosen 'O' as his marker when we created the game and deferred from going
first. The idea here is that whoever creates the game gets to choose their marker and whether or not they want to go
first and is set as player1.

**NOTE**: We have the following game creation scenarios:
1. Player1 chooses to be 'X' and chooses 'X' to go first
2. Player1 chooses to be 'X' and chooses 'O' to go first
3. Player1 chooses to be 'O' and chooses 'O' to go first
4. Player1 chooses to be 'O' and chooses 'X' to go first

## List available games to join

Here we list all `waiting` public games so that they can be joined by other players as player2.

**Example Request** - List all available `waiting` public games

_Security Note_: Here we have to make sure we do not expose any player codes other than the current player.
```
GET /api/game/ HTTP/1.1
Host: localhost:5000
Content-Type: application/json
```

**Example Response**
```
200 OK
[
    // Here we have Dan starting a game as 'X' and choosing to go first
    {
        "game_id": 1,
        "is_public": true,
        "player1_id": 1,
        "player1": {
            "player_id": 1,
            "player_name": "Dan",
            "player_mark": "X"
        },
        "player2_id": null,
        "current_player_id": 1,
        "current_player": {
            "player_id": 1,
            "player_name": "Dan",
            "player_mark": "X"
        },
        "winning_player_id": null,
        "game_status_value": "waiting",
        "game_board": "[1,2,3,4,5,6,7,8,9]",
        "game_auth_code": "dbd2da0f-e6de-47a5-ac57-c198b13913cf",
        "win_state_value": null
    },
    // Here we have Ben starting a game as 'O' and choosing to go second
    {
        "game_id": 2,
        "is_public": true,
        "player1_id": 2,
        "player1": {
            "player_id": 2,
            "player_name": "Ben",
            "player_mark": "O"
        },
        "player2_id": null,
        "current_player_id": null,
        "winning_player_id": null,
        "game_status_value": "waiting",
        "game_board": "[1,2,3,4,5,6,7,8,9]",
        "game_auth_code": "760bf7e8-aab7-48d2-bca9-0640a15a7ae8",
        "win_state_value": null
    }
]
```

## Join a waiting available game

This operation allows a player to join a `waiting` available or public game. In the future private game support could be
added.

**Example Request** - Join an avaliable game

_Security Note_: This is a public method but we should ensure that we do not expose player1's code to the joining player2.
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
chose. Once the game is joined we generate player2's code so that it can be used in conjunction with the game
authorization code to make moves for player2.

**Example Response** - Successful game join
```
201 Created
Location: http://localhost:5000/api/game/1
{
    "game_id": 1,
    "is_public": true,
    "player1_id": 1,
    "player1": {
        "player_id": 1,
        "player_name": "Dan",
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
        "player_mark": "X"
    },
    "winning_player_id": null,
    "game_status_value": "running",
    "game_board": "[1,2,3,4,5,6,7,8,9]",
    "game_auth_code": "dbd2da0f-e6de-47a5-ac57-c198b13913cf",
    "win_state_value": null
}
```

In the above example 'Ben' is using the 'O' marker and is going second because 'Dan' chose the 'X' marker and to go
first when he created the game. Also note that each player now has a player code which we will use later to validate
moves along with the game authorization code.

**Example Response** - Invalid game authorization code
```
400 Bad Reauest
{ "code": 400, "message": "Invalid game authorization code."}
```

**Example Response** - Error joining a game that is not in the `waiting` status
```
400 Bad Reauest
{ "code": 400, "message": "Can only join a waiting available game"}
```

## Get an individual game

Get an representation of an individual game.

**Example Request** - Get an individual game

_Security Note_: For this GET endpoint, the user code and the game auth code must be provided in the appropriate headers
`X-User-Code` and `X-Game-Auth-Code` respectively when making a request.
```
GET /api/game/:game_id HTTP/1.1
Host: localhost:5000
Content-Type: application/json
X-User-Code: 05e0b43c-1dd7-45e5-b90c-b3fce80acb21
X-Game-Auth-Code: dbd2da0f-e6de-47a5-ac57-c198b13913cf
```

**Example Response**
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
        "player2_mark": "O",
    },
    "current_player_id": 1,
    "current_player": {
        "player_id": 1,
        "player_name": "Dan",
        "player_code": "05e0b43c-1dd7-45e5-b90c-b3fce80acb21",
        "player_mark": "X"
    },
    "winning_player_id": null,
    "game_status_value": "running",
    "game_board": "[1,2,3,4,5,6,7,8,9]",
    "game_auth_code": "dbd2da0f-e6de-47a5-ac57-c198b13913cf",
    "win_state_value": null
}
```

**Example Response** - Game not found
```
404 Bad Reauest
{ "code": 404, "message": "Game not found for id ':id'." }
```

**Example Response** - Not authorized
```
401 Unauthorized
{ "code": 401, "message": "You are not authorized to view this game"}
```

## Make a move on the game board

Here we number the game board indices 1 - 9. The example request is placing an 'X' on the 1 spot on the board which is the
upper left corner.

### Example Board Indices

```
1 | 2 | 3
---------
4 | 5 | 6
---------
7 | 8 | 9
```

**Example Request**

_Security Note_: In order to make a move on the game board you must have a proper player code and game authorization
code.
```
POST /api/game/:id/move/:index HTTP/1.1
Host: localhost:5000
Content-Type: application/json
{
    "player_code": "05e0b43c-1dd7-45e5-b90c-b3fce80acb21",
    "game_auth_code": "dbd2da0f-e6de-47a5-ac57-c198b13913cf"
}
```

**Example Response**
```
201 Created
Location: http://localhost:5000/api/game/1
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
        "player2_mark": "O",
    },
    "current_player_id": 1,
    "current_player": {
        "player_id": 1,
        "player_name": "Dan",
        "player_code": "05e0b43c-1dd7-45e5-b90c-b3fce80acb21",
        "player_mark": "X"
    },
    "winning_player_id": null,
    "game_status_value": "running",
    "game_board": "[X,2,3,4,5,6,7,8,9]",
    "game_auth_code": "dbd2da0f-e6de-47a5-ac57-c198b13913cf",
    "win_state_value": null
}
```

**Example Response** - Game not found
```
404 Bad Reauest
{ "code": 404, "message": "Game not found for id ':id'." }
```

**Example Response** - Not authorized
```
401 Unauthorized
{ "code": 401, "message": "You are not authorized to make a move on this game board"}
```

**Example Response** - Error making a move on a game that isn't running
```
400 Bad Reauest
{ "code": 400, "message": "Cannot make a move on a game that is not running"}
```

**Example Response** - Error moving out of turn
```
400 Bad Reauest
{ "code": 400, "message": "Player1 cannot move out of turn"}
```

**Example Response** - Error moving to an occupied space
```
400 Bad Reauest
{ "code": 400, "message": "You cannot move to space '1' because it is already occupied"}
```

## Game Win State Conditions

Here we will illustrate various 'complete' games and their possible win states. These examples are a bit contrived and
not necessarily complete, however 16 different win conditions were checked in in the ReST tests. We checked all 8 known
win conditions for classic Tic Tac Toe with both 'X' and 'O' markers.

### Player1 wins

```
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
        "player2_mark": "O",
    },
    "current_player_id": 1,
    "current_player": {
        "player_id": 1,
        "player_name": "Dan",
        "player_code": "05e0b43c-1dd7-45e5-b90c-b3fce80acb21",
        "player_mark": "X"
    },
    "winning_player_id": 1,
    "winning_player": {
        "player_id": 1,
        "player_name": "Dan",
        "player_code": "05e0b43c-1dd7-45e5-b90c-b3fce80acb21",
        "player_mark": "X"
    },
    "game_status_value": "complete",
    "game_board": "[X,O,3,X,O,6,X,8,9]",
    "game_auth_code": "dbd2da0f-e6de-47a5-ac57-c198b13913cf",
    "win_state_value": "player1"
}
```

### Player2 wins

```
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
        "player2_mark": "O",
    },
    "current_player_id": 1,
    "current_player": {
        "player_id": 1,
        "player_name": "Ben",
        "player_mark": "O"
    },
    "winning_player_id": 1,
    "winning_player": {
        "player_id": 1,
        "player_name": "Ben",
        "player_mark": "O"
    },
    "game_status_value": "complete",
    "game_board": "[ X,X,3,O,X,X,O,O,O]",
    "game_auth_code": "dbd2da0f-e6de-47a5-ac57-c198b13913cf",
    "win_state_value": "player2"
}
```

### Cats Game - tied

```
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
        "player2_mark": "O",
    },
    "current_player_id": 1,
    "current_player": {
        "player_id": 1,
        "player_name": "Ben",
        "player_mark": "O"
    },
    "winning_player_id": null,
    "game_status_value": "complete",
    "game_board": "[X,X,O,O,O,X,X,O,X]",
    "game_auth_code": "dbd2da0f-e6de-47a5-ac57-c198b13913cf",
    "win_state_value": "cats"
}
```

## Caveats and Issues

There are a number of caveats and issues with my approach and what I have impelemented thus far.

1. It may be simpler just to implement real user registration and authentication so enforcing permissions and deciding
   on what user codes to display isn't so cumbersome. For now I do not have any checks in place preventing other players
   from seeing player codes that they should not see.
2. There are most likely concurrency issues with creating games, joining and move operations. If I used PostgreSQL then
   I would most likely have used an advisory lock to serialize access and avoid race conditions. One could also use some
   sort of optimistic locking as well possibly. I'm sure there are other solutions as well.
3. I did not implement any sort of REST data/params validation to save some time but I most likely would use
   Params::Validate or Data::Formvalidator. I also didn't validate the data before save()'ing it in the DB tables.
4. I used SQLite as the backend database but that choice was made for ease of administration and ease of
   building or prepping a test DB for use in running the tests.
5. I did not write any unit tests for the Game::TicTacToe namespace modules which were based on Games::TicTacToe on
   CPAN but slightly modified to fit my data model and game play.
6. I did not end up using or setting the win_state_value column in the game board. I don't think it would be too much
   trouble but I am skipping it for now.
7. I am not handling any exceptions in the endpoints or anywhere really via say Try::Tiny even though Dancer2 does a
   pretty good job of catching them. You can probably finagle and ugly stack trace inside the error JSON structure. The
   same thing goes for REST params and DB data validation.
8. I also did not write any POD but if this was a more professional/work app I'd probably force myself to do that or at
   least get back into the swing of that.

#!/bin/bash

## PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"
PSQL="psql -X --username=freecodecamp --dbname=number_guess --tuples-only -c"

echo -e "\n ~~~~~ Number Guessing Game ~~~~~ \n"

# get a player name
echo -e "Enter your username:"
read PLAYER

# if player found
RESULT=$($PSQL "SELECT MAX(p.player_id), COUNT(g.game_id), MIN(g.guesses) \
                     FROM players AS p \
                     RIGHT JOIN games AS g USING(player_id) \
                     WHERE p.name = '$PLAYER';")
read PLAYER_ID BAR NUM_GAMES BAR MIN_GUESSES <<< "$RESULT" 

# if result is empty new player
if [[ $PLAYER_ID == "|" ]]
then
  # welcom new player
echo -e "\nWelcome, $PLAYER! It looks like this is your first time here."
else
  # welcom existing player
  echo -e "\nWelcome back, $PLAYER! You have played $NUM_GAMES games, and your best game took $MIN_GUESSES guesses."
fi

# generate and store a random number INT between 1 and 1000
GNUM=$((1 + $RANDOM % 1000))
# echo "GNUM is $GNUM"
# set a guess variable INT to store guess
echo -e "\nGuess the secret number between 1 and 1000:"
read GUESS
GUESSES=1
# while the nuber is not guessed
while [[ $GUESS != $GNUM ]]
do
  ## while guess isn't an INT
  while [[ ! $GUESS =~ ^[0-9]+$ ]]
    do
    echo -e "\nThat is not an integer, guess again:"
    read GUESS
  done
  ## incriment gusses
  ((GUESSES++))

  # cheat to see num for bug "higher than 399, lower than 400" WTF
  if [[ $GUESS == 000 ]]
  then
    echo -e "$GNUM"
  fi
  # give a hint and get another guess
  if [[ $GUESS < $GNUM ]]
  then
    echo -e "\nIt's higher than that, guess again:"
    read GUESS
  else
    echo -e "\nIt's lower than that, guess again:"
    read GUESS
  fi
done

if [[ $PLAYER_ID == "|" ]]
then
  RESULT=$($PSQL "INSERT INTO players(name) VALUES('$PLAYER');")
  PLAYER_ID=$($PSQL "SELECT player_id FROM players WHERE name = '$PLAYER'")
fi

### store game data
RESULT=$($PSQL "INSERT INTO games(player_id, guesses) \
                VALUES($PLAYER_ID, $GUESSES);")

# tell player they won
echo -e "guesses=-$GUESSES-, number=-$GNUM-."
echo -e "You guessed it in $GUESSES tries. The secret number was $GNUM. Nice job!"

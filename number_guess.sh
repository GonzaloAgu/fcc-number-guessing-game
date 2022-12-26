#!/bin/bash

# psql variable
PSQL="psql --username=freecodecamp --dbname=postgres -t --no-align -c"
# generate secret number
SECRET_NUMBER=$[$RANDOM % 1000]

START_GAME() {
  echo -e "\nGuess the secret number between 1 and 1000:"
  read GUESS
  GUESSES=1
  while [[ $GUESS -ne $SECRET_NUMBER ]]
  do
    if [[ ! $GUESS =~ ^[0-9]+$ ]]; then
      echo -e "\nThat is not an integer, guess again:"
      read GUESS
    else
      if [[ $GUESS -gt $SECRET_NUMBER ]]; then
        echo -e "\nIt's lower than that, guess again:"
        read GUESS
      else
        echo -e "\nIt's higher than that, guess again:"
        read GUESS
      fi
    fi
    # increment amount of guesses
    ((GUESSES += 1))
  done

  # if new record or first game, add it to database
  if [[ -z $PB || $GUESSES -lt $PB ]]; then
    ADD_PB=$($PSQL"UPDATE users SET personal_best = $GUESSES WHERE user_id = $ID_RESULT;")
  fi
  # increment games_played in database
  ((GAMES_PLAYED += 1))
  UPDATE_GAMES_PLAYED=$($PSQL"UPDATE users SET games_played = $GAMES_PLAYED WHERE user_id = $ID_RESULT")

  echo -e "\nYou guessed it in $GUESSES tries. The secret number was $SECRET_NUMBER. Nice job!"
}

# ask for user information
echo Enter your username:
read USERNAME

# look ID for that username in database
ID_RESULT=$($PSQL"SELECT user_id FROM users WHERE name='$USERNAME';")

if [[ -z $ID_RESULT ]]; then
# if user doesn't exist:
  # create the user in the db
  CREATE_USER=$($PSQL"INSERT INTO users(name, games_played) VALUES('$USERNAME', 0);")
  ID_RESULT=$($PSQL"SELECT user_id FROM users WHERE name='$USERNAME';")
  GAMES_PLAYED=0
  # print message
  echo -e "\nWelcome, $USERNAME! It looks like this is your first time here."
  # start game
  START_GAME
else
# if it does
  # look for user data
  GAMES_PLAYED=$($PSQL"SELECT games_played FROM users WHERE user_id=$ID_RESULT;")
  PB=$($PSQL"SELECT personal_best FROM users WHERE user_id=$ID_RESULT;")
  # print message
  echo -e "\nWelcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $PB guesses."
  # start game
  START_GAME
fi


#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

MENU() {
  echo Enter your username:
  read USERNAME
}

MENU
while [[ -z $USERNAME ]]; 
do 
  MENU "A username is reqired."
done
USER=$($PSQL "SELECT name,num_games_played,best_game FROM users WHERE name='$USERNAME'")


if [[ -z $USER ]]
then 
  echo Welcome, $USERNAME! It looks like this is your first time here.
  INSERT_USER=$($PSQL "insert into users(name, num_games_played, best_game) values('$USERNAME', 1,1000)")
else 
  echo "$USER" | while IFS="|" read USER NUM_GAMES BEST_SCORE; do
      echo Welcome back, $USER! You have played $NUM_GAMES games, and your best game took BEST_SCORE guesses.   
    ((NUM_GAMES++))
    UP_GAMES=$($PSQL "update users set num_games_played=$NUM_GAMES where name='$USER'")
  done 
fi

GUESS() {
  echo -e "\nGuess the secret number between 1 and 1000:"
  read NUMBER
}

GUESS
# Guess and counter 
GUESS_NUMBER=$((RANDOM % 1000 + 1))
GUESS_COUNT=1
echo $GUESS_NUMBER

while [[ $NUMBER != $GUESS_NUMBER ]]; do
  if ! [[ $NUMBER =~ ^[0-9]+$ ]]; then
      echo "That is not an integer, guess again:"
      GUESS 
  elif [[ $NUMBER > $GUESS_NUMBER ]]; then
      echo "It's lower than that, guess again:"
      GUESS 
  elif [[ $NUMBER < $GUESS_NUMBER ]]; then
      echo "It's higher than that, guess again:"
      GUESS 
  fi 
  ((GUESS_COUNT++))
done

BEST_SCORE=$($PSQL "select best_game from users where name='$USERNAME'")
if [[ $BEST_SCORE -gt $GUESS_COUNT ]]; then
  UPDATE_SCORE=$($PSQL "update users set best_game=$GUESS_COUNT where name='$USERNAME'")
fi 

echo You guessed it in $GUESS_COUNT tries. The secret number was $GUESS_NUMBER. Nice job!

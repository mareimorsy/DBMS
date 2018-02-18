#!/bin/bash
clear
cat ./config/intro

unset selected_db

if [[ -n $selected_db ]]; then
	PS3="MareiDB [ $selected_db ] > "
else
	PS3="MareiDB [ (none) ] > "
fi

select choice in "Use Database" "Create Database" "Drop Database" "Exit Marei DBMS"
do
case $choice in
# ========================== USE DATABASE ==========================
"Use Database") read -p "[Enter the Database name]: " answer
	if [ -d "./data/$answer" ]; then
	  export selected_db=$answer
	  ./database.sh
	  break
	else
		echo "Database '$answer' doesn't exist!"
fi
;;
# ========================== CREATE DATABASE ==========================
"Create Database") read -p "[Enter the Database name]: " answer
	if [ -d "./data/$answer" ]; then
	  echo "Database $answer already exists"
	else
	  	mkdir -p ./data/$answer/tables ./data/$answer/metadata
		echo "Database '$answer' has created Successfully!"
	fi
;;
# ========================== DROP DATABASE ==========================
"Drop Database") read -p "[Enter the Database name that you want to DROP!!!]: " answer
	if [ -d "./data/$answer" ]; then
	  rm -rf ./data/$answer
	  echo "Database $answer has dropped Successfully!"
	else
	  	echo "Database '$answer' doesn't exist!"
	fi
;;
# ========================== EXIT Marei DBMS ==========================
"Exit Marei DBMS") echo "bye!"
break
;;
*) echo $REPLY is not one of the choices.
;;
esac
done
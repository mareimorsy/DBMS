#!/bin/bash
clear
echo "Please enter the number of the option that you would like to select"
echo
if [[ -n $selected_db ]]; then
	PS3="MareiDB [ $selected_db ] > "
else
	echo "No database selected, you have to use one first!"
	./main.sh
fi

select choice in "Select table" "Show tables" "Create table" "Drop table" "Back to the main menu"
do
case $choice in
# ========================== SELECT TABLE ==========================
"Select table") read -p "[Enter the Table name]: " answer
	if [ -f "./data/$selected_db/tables/$answer" ]; then
		export selected_table=$answer
		./table.sh
		break
	else
		echo "Table '$answer' doesn't exist!"
	fi
;;
# ========================== SHOW TABLES ==========================
"Show tables")
echo "+------------+"
echo "|   TABLES   |"
echo "+------------+"
for i in $( ls ./data/$selected_db/tables); do
	echo -e "| $i\t     |"
	echo "+------------+"
done
;;
# ========================== CREATE TABLE ==========================
"Create table") read -p "[Enter the Table name]: " answer
	if [ -f "./data/$selected_db/tables/$answer" ]; then
		echo "Table '$answer' already exists!"
	else
		touch ./data/$selected_db/tables/$answer
		touch ./data/$selected_db/metadata/$answer
		echo "Table '$answer' has created successfully!"
		echo
		PS3="MareiDB [ $selected_db:$answer.$col_name ] > "
		read -p "[Enter the number of columns]: " col_num
		for (( i = 1; i <= col_num; i++ )); do
			read -p "[Enter the name of column #$i]: " col_name
			if [[ -z $col_name ]]; then
				((i--))
				continue
			fi

			PS3="MareiDB [ $selected_db:$answer.$col_name ] > "
			echo "Please enter the type of column $col_name"
			select choice in "Number" "String"
			do
			case $choice in
				"Number")
				break
				;;
				"String")
				break
				;;
				*) echo $REPLY is not one of the choices.
				;;
				esac
				done
				echo $col_name:$choice>> ./data/$selected_db/metadata/$answer
				PS3="MareiDB [ $selected_db ] > "
		done
	fi
	read -p "[Do you want to set a primary key for table $answer?] (y/n): " user_reply
	if [[ $user_reply == y || $user_reply == Y || $user_reply == yes || $user_reply == YES ]]; then

		while [[ true ]]; do
			read -p "[Enter the column name that you want to assign as a Primary key]: " pk
			table_col_name=`awk -F: '{if($1=='"\"$pk\""'){print $1}}' ./data/$selected_db/metadata/$answer`
			if [[ $table_col_name == $pk ]]; then
				awk -F: '{if($1=='"\"$pk\""'){print $0":pk"}else{print $0}}' ./data/$selected_db/metadata/$answer > tmp
				mv tmp ./data/$selected_db/metadata/$answer
				break
			else
				echo "can't find column called $pk"
				continue
			fi
		done
	fi
;;
# ========================== DROP TABLE ==========================
"Drop table") read -p "[Enter the Table name]: " answer
if [ -f "./data/$selected_db/tables/$answer" ]; then
	rm ./data/$selected_db/tables/$answer
	rm ./data/$selected_db/metadata/$answer
	echo "Table '$answer' has drppped successfully!"
else
	echo "Table '$answer' doesn't exist exists!"
fi
;;
# ========================== BACK TO MAIN MENU ==========================
"Back to the main menu")
./main.sh
break
break
;;
*) echo $REPLY is not one of the choices.
;;
esac
done
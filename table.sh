#!/bin/bash
# echo "$selected_db $selected_table"

#!/bin/bash
clear
is_numeric () {
	re='^-?[0-9]+([.][0-9]+)?$'
	if [[ $1 =~ $re ]] ; then
		return 1
	else
	   return 0
	fi
}

read_lines(){
	counter=0
	unset rows
	while read row; do
	rows[$counter]=$row
	# echo ${rows[$counter]}
	((counter++))
	done < $1
	# echo ${#rows[@]} #the arr length
}

echo "Please enter the number of the option that you would like to select"
echo
if [[ -n $selected_db ]]; then
	PS3="MareiDB [ $selected_db ] > "
else
	echo "No database selected, you have to use one first!"
	./main.sh
fi

if [[ -n $selected_table ]]; then
	PS3="MareiDB [ $selected_db:$selected_table ] > "
else
	echo "No table selected, you have to use one first!"
	./database.sh
fi

select choice in "Insert" "Display" "Description" "Update" "Delete" "Back to tables menu"
do
case $choice in
# ========================== SELECT TABLE ==========================
"Insert")
pk=`awk -F: '{if($3=="pk"){print $1}}' ./data/$selected_db/metadata/$selected_table`
pk_num=`awk -F: '{if($3=="pk"){print NR}}' ./data/$selected_db/metadata/$selected_table`

read_lines "./data/$selected_db/metadata/$selected_table"
i=1
for row in "${rows[@]}";do
	col_name=`echo $row | cut -d: -f1`
	col_type=`echo $row | cut -d: -f2`

	while [[ true ]]; do
		read -p "[ MareiDB $selected_db:$selected_table.$col_name ]: " col_val

		if [[ $col_val == ":" ]]; then
			echo "the : is considered as a special charachter in MareiDB"
			continue
		fi

		if [[ -z $col_val && $col_name == $pk ]]; then
			echo "The column $col_name is a primary key and it can't be null"
			continue
		elif [[ -n $col_val && $col_name == $pk ]]; then
			repeated=$(awk -F: "{if(\$$pk_num==\"$col_val\"){print NR}}" ./data/$selected_db/tables/$selected_table)

			if [[ -n $repeated ]]; then
				echo "The column $col_name is a primary key and its values must be unique"
				continue
			fi
		fi

		if [[ $col_type == "Number" ]]; then

			is_numeric $col_val
			if [[ $? -eq 1 ]]; then
				# if last iteration don't append :
				if [[ $i -eq  ${#rows[@]} ]]; then
					new_row+=$col_val
				else
					new_row+=$col_val:
				fi
				((i++))
				break
				else
				echo "The column $col_name is numeric, it can't be string"
				continue
			fi

		else #if string
			# if last iteration don't append :
			if [[ $i -eq  ${#rows[@]} ]]; then
				new_row+=$col_val
			else
				new_row+=$col_val:
			fi
			((i++))
			break
		fi
	done

done
echo $new_row >> ./data/$selected_db/tables/$selected_table
unset new_row
;;
# ========================== SHOW TABLES ==========================
"Display")
./select.sh
break
;;
# ========================== CREATE TABLE ==========================
"Description")
cat ./data/$selected_db/metadata/$selected_table
;;
# ========================== DROP TABLE ==========================
"Update")
./update.sh
break
;;
# ========================== DROP TABLE ==========================
"Delete")
./delete.sh
;;
# ========================== BACK TO MAIN MENU ==========================
"Back to tables menu")
./database.sh
break
;;
*) echo $REPLY is not one of the choices.
;;
esac
done
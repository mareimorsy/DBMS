#!/bin/bash
clear

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

echo "Enter the values of the new row"
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



# UPDATE
unset new_row
pk=`awk -F: '{if($3=="pk"){print $1}}' ./data/$selected_db/metadata/$selected_table`
pk_num=`awk -F: '{if($3=="pk"){print NR}}' ./data/$selected_db/metadata/$selected_table`

read_lines "./data/$selected_db/metadata/$selected_table"
i=1
for row in "${rows[@]}";do
	col_name=`echo $row | cut -d: -f1`
	col_type=`echo $row | cut -d: -f2`

	while [[ true ]]; do
		read -p "[ MareiDB $selected_db:$selected_table.$col_name ]: " col_val
		if [[ -z $col_val && $col_name == $pk ]]; then
			echo "The column $col_name is a primary key and it can't be null"
			continue
		fi

		if [[ $col_val == "*" ]]; then
			if [[ $i -eq  ${#rows[@]} ]]; then
				new_row+=$col_val
			else
				new_row+=$col_val:
			fi
			((i++))
			break
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
# echo $new_row

#End Update
clear
echo "Enter the option number that you would like to be used as updating criteria"
echo

pk=`awk -F: '{if($3=="pk"){print $1}}' ./data/$selected_db/metadata/$selected_table`
pk_num=`awk -F: '{if($3=="pk"){print NR}}' ./data/$selected_db/metadata/$selected_table`

read_lines "./data/$selected_db/metadata/$selected_table"
i=1
for row in "${rows[@]}";do
	col_name=`echo $row | cut -d: -f1`
	col_type=`echo $row | cut -d: -f2`
	echo "$i) $col_name [$col_type]"
	((i++))
done
echo "$i) Back to table menu"
while [[ true ]]; do
	read -p "[ MareiDB $selected_db:$selected_table ] #? " col_num
	selected_col=$col_num
	if [[ -z $col_num ]]; then
		continue
	elif [[ $col_num -gt $i || $col_num -lt 1 ]]; then
		echo "$col_num is not one of the options"
		continue
	fi

	if [[ $col_num -eq $i ]]; then
		./table.sh
		break
	fi
	((col_num--))

	col_name=`echo ${rows[$col_num]} | cut -d: -f1`
	col_type=`echo ${rows[$col_num]} | cut -d: -f2`
	echo "Select an operator to be used in updating criteria"
	PS3="MareiDB [ $selected_db:$selected_table.$col_name ] #? "
	select choice in "==" "!=" ">" ">=" "<" "<="
	do
	case $choice in
	">")
	break
	;;
	"<")
	break
	;;
	"==")
	break
	;;
	"!=")
	break
	;;
	">=")
	break
	;;
	">=")
	break
	;;
	*) echo $REPLY is not one of the choices.
	;;
	esac
	done

	while [[ true ]]; do
		read -p "[ Update if $col_name $choice ] #? " col_val
			lines=$(awk -F: "{if(\$$selected_col$choice\"$col_val\"){print \$0}}" ./data/$selected_db/tables/$selected_table)
			if [[ $col_type == "Number" ]]; then

				is_numeric $col_val
				if [[ $? -eq 1 ]]; then
					lines=$(awk -F: "{if(\$$selected_col$choice$col_val){print \$0}}" ./data/$selected_db/tables/$selected_table)
				else
					echo "The column $col_name is numeric, it can't be string"
					continue
				fi
			fi
			((col_num++))

			affected_rows=0
			for line in $lines; do
				for (( i = 1; i <= ${#rows[@]}; i++ )); do
					# echo $i
					old_val=`echo $line | cut -d: -f$i`
					new_val=`echo $new_row | cut -d: -f$i`
					col_name=`echo ${rows[$i-1]} | cut -d: -f1`

					if [[ $new_val != "*" && $col_name == $pk ]]; then
						repeated=$(awk -F: "{if(\$$pk_num==\"$new_val\"){print NR}}" ./data/$selected_db/tables/$selected_table)
					fi

					if [[ $new_val == "*" ]]; then
						new_val=$old_val
					fi

					if [[ $i -eq  ${#rows[@]} ]]; then
						final_row+=$new_val
					else
						
						final_row+=$new_val:
					fi
				done
					if [[ -n $repeated ]]; then
						echo "The column $col_name is a primary key and its values must be unique"
						continue
					else
						sed -i "s/$line/$final_row/g" ./data/$selected_db/tables/$selected_table
						unset final_row
						((affected_rows++))
					fi
			done
			echo "$affected_rows rows has updated successfully!"
			break
	done

done
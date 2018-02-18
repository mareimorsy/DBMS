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

echo "Enter the option number that you would like to select"
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

echo "$i) Delete * rows"
((i++))
echo "$i) Back to table menu"
while [[ true ]]; do
	read -p "[ MareiDB $selected_db:$selected_table ] #? " col_num
	if [[ -z $col_num ]]; then
		continue
	elif [[ $col_num -gt $i || $i -lt 1 ]]; then
		echo "$col_num is not one of the options"
		continue
	fi

	if [[ $col_num -eq $i-1 ]]; then
		lines_num=`wc -l ./data/$selected_db/tables/$selected_table | cut -d' ' -f1`
		rm ./data/$selected_db/tables/$selected_table 
		touch ./data/$selected_db/tables/$selected_table 
		echo "$lines_num rows has deleted successfully!"
		break
	fi

	if [[ $col_num -eq $i ]]; then
		./table.sh
		break
	fi
	((col_num--))

	col_name=`echo ${rows[$col_num]} | cut -d: -f1`
	col_type=`echo ${rows[$col_num]} | cut -d: -f2`
	echo "Select an operator to be used in deletion"
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
		read -p "[ Delete if $col_name $choice ] #? " col_val

			if [[ $col_type == "Number" ]]; then

				is_numeric $col_val
				if [[ $? -eq 1 ]]; then
					# echo "Delete Numeric"
					((col_num++))
					lines_num=$(awk -F: "{if(\$$col_num$choice$col_val){print NR}}" ./data/$selected_db/tables/$selected_table)
					affected_rows=0
					for i in $lines_num; do
						cmd="$cmd"" -e "$i"d"
						((affected_rows++))
					done
					sed $cmd ./data/$selected_db/tables/$selected_table > tmp
					mv tmp ./data/$selected_db/tables/$selected_table
					echo "$affected_rows rows has deleted successfully!"
					break
					else
					echo "The column $col_name is numeric, it can't be string"
					continue
				fi
			fi
			# echo "Delete string"
			((col_num++))
			lines_num=$(awk -F: "{if(\$$col_num$choice\"$col_val\"){print NR}}" ./data/$selected_db/tables/$selected_table)
			affected_rows=0
			for i in $lines_num; do
				cmd="$cmd"" -e "$i"d"
				((affected_rows++))
			done
			sed $cmd ./data/$selected_db/tables/$selected_table > tmp
			mv tmp ./data/$selected_db/tables/$selected_table
			echo "$affected_rows rows has deleted successfully!"
			break
	done

done
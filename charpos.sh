if [ $# -ne 2 -a $# -ne 3 ]
then
	app=`basename $0`
	echo "Usage: $app <character> <position> [-]" 1>&2
	echo "        - : charater is NOT at the position"  1>&2
	exit 1
fi

NOT_THERE=0
if [ $# -eq 3 ]
then
	if [ $3 != '-' ]
	then
		echo "3rd parameter must be '-'"  1>&2
		exit 2
	fi
	NOT_THERE=1
fi

CHAR=$1
POS=$2

awk -v pos=$POS -v char=$CHAR -v not_there=$NOT_THERE '
	BEGIN {
		FS="[ .,]"
	}
	{
		for(i=1;i<=NF;i++) {
			word=tolower($i)
			word=trim(word)
			#printf "#%s#\n", word
		
			if (not_there == 0) {
				if (substr(word,pos,1) == char) print word
			}
			else {
				if (substr(word,pos,1) != char) print word
			}
		}
	}

	function trim(s)
	{
		gsub("^[ ]*", "", s)
		gsub("[ ]*$", "", s)
		return s
	}	
' | sort -u

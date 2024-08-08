
if [ $# -ne 2 ]
then
	app=`basename $0`
	echo "Usage: $app <character> <position>" 1>&2
	exit 1
fi

CHAR=$1
POS=$2

awk -v pos=$POS -v char=$CHAR '
	BEGIN {
		FS="[ .,]"
	}
	{
		for(i=1;i<=NF;i++) {
			word=tolower($i)
			word=trim(word)
			#printf "#%s#\n", word
		
			if (substr(word,pos,1) == char) print word
		}
	}

	function trim(s)
	{
		gsub("^[ ]*", "", s)
		gsub("[ ]*$", "", s)
		return s
	}	
' | sort -u

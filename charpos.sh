
if [ $# -ne 2 ]
then
	app=`basename $0`
	echo "Usage: $app <position> <character>" 1>&2
	exit 1
fi

POS=$1
CHAR=$2

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
'

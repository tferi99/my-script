#!/bin/bash
########################################################################################
# To get words from a text file, where the word
#	- has the specified length
#	- contains ALL included characters 
#	- and does not contain ANY excluded cgaracters
########################################################################################

if [ $# -lt 1 -a $# -gt 3 ]
then
	app=`basename $0`
	echo "Usage: $app [[[<len>] <letters-included>] <letters-excluded>]" 1>&2
	echo "       len <= 0 : any length" 1>&2
	exit 1
fi


LEN=$1
INC=$2
EXC=$3

if [ -z $1 ]
then
	echo 'EMPTY 1'
	LEN=0
fi

if ! [[ "$LEN" =~ ^[0-9]+$ ]]
then
	echo "$LEN : is not a number" 1>&2
	exit 2
fi

awk -v len="$LEN" -v inc="$INC" -v exc="$EXC" '
	BEGIN {
		FS="[ .,]"
	
		inc=trim(inc)
		exc=trim(exc)
		hasInc=length(inc) > 0;
		hasExc=length(exc) > 0;
		#printf "inc: %s; hasInc: %d\n", inc, hasInc;
		#printf "exc: %s; hasExc: %d\n", exc, hasExc;
		
		incCharsLen = split(inc, incChars, "")
		for (i = 1; i <= incCharsLen; i++) {
			printf "    - INC_CHAR[%s]\n", incChars[i]
		}
		exc="[" exc "]"
	}	
	{
		# NOTE: word !~ "[" + exc + "]" : it means that work does not contain ANY characters from exc
		for (i = 1; i <= NF; i++) {
			word=tolower($i)
			word=trim(word)
			#printf "########################### WORD[%s]\n", word
			if (len > 0) {
				if (hasInc && hasExc) {
					#printf "L-I-E\n";
					if (length(word) == len && containsAll(word, incChars, incCharsLen) && word !~ exc) {
						print word
					}
				}
				else if (hasInc) {
					#printf "L-I\n";
					if (length(word) == len && containsAll(word, incChars, incCharsLen)) {
						print word
					}
				}			
				else if (hasExc) {
					#printf "L-E\n";
					if (length(word) == len && word !~ exc) {
						print word
					}
				}			
				else {
					#printf "L\n";
					if (length(word) == len) {
						print word
					}
				}			
			}
			else {
				if (hasInc && hasExc) {
					if (containsAll(word, incChars, incCharsLen) && word !~ exc) {
						print word
					}
				}
				else if (hasInc) {
					if (containsAll(word, incChars, incCharsLen)) {
						print word
					}
				}			
				else if (hasExc) {
					if (word !~ exc) {
						print word
					}
				}
				else {
					print word
				}
			}
		}
	}

	# all characters can be found in string
	function containsAll(str, chars, charsLen)
	{
		#printf ">>> containsAll [%s][%d]\n",  str, charsLen
		found_all = 1;
		for (c = 1; c <= charsLen; c++) {
			#printf "        - contains [%s][%s]\n", str, chars[c]
			if (index(str, chars[c]) == 0) {
				found_all = 0;
				break;
			}
		}
		return found_all
	} 	 	

	function trim(s)
	{
		gsub("^[ ]*", "", s)
		gsub("[ ]*$", "", s)
		return s
	}
	
	function alen(a, i, k) {
		k = 0
		for(i in a) k++
		return k
	}	
' | sort -u | grep -E '^[A-Za-z]+$'





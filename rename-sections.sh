#
# MIT License
#
# Copyright (c) 2011-2018 Pedro Henrique Penna <pedrohenriquepenna@gmail.com>
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.  THE SOFTWARE IS PROVIDED
# "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT
# LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR
# PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
# HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
# ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#


ARCHIVE=$1
LIBNAME=$2

parameters=()

prefixes=(user barelib hal microkernel libnanvix ulibc multikernel libmpi)

for section in text data bss rodata; 
do
	section_names=$(
		$OBJDUMP -h $ARCHIVE           | \
		grep -E -o  "\.\S*$section\S*" | \
		xargs -n1                      | \
		sort -u                        | \
		xargs
	)
	for name in $section_names;
	do
		valid=1
		name_prefix="$(cut -d . -f 2 <<< $name)"
		for prefix in ${prefixes[@]};
		do
			if [ $name_prefix == $prefix ]; then
				valid=0
				break
			fi
		done;
		if [ $valid -eq 1 ];
		then
			parameters+=(--rename-section $name=.$LIBNAME$name)
		fi
	done;
done;

$OBJCOPY $ARCHIVE ${parameters[*]} $ARCHIVE

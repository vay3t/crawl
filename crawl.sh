#!/bin/bash
# coded by vay3t!

arr=()

function domain(){
	echo $1 | cut -d "/" -f3
}

function protocol(){
	echo $1 | cut -d ":" -f1
}

function in_array() {
	local hay needle=$1
	shift
	for hay; do
		[[ $hay == $needle ]] && return 0
	done
	return 1
}

function obtain_urls(){
	for link in $(curl -s $1 | hxnormalize | grep href | cut -d '"' -f2| sort -u); do
		echo $link | egrep "https?://" | grep $(domain $1) &> /dev/null
		if [ $? -eq 0 ]; then
			new_link=$(echo $link | sed -e "s/https\?\:\/\/$(domain $1)//g")
			if [ ! -z $new_link ]; then
				booleano=$(in_array $new_link "${arr[@]}" && echo yes || echo no)
				if [ $booleano == "no" ]; then
					arr=("${arr[@]}" $new_link)
					echo $link
					obtain_urls $link
				fi
			fi
		else
			echo $link | egrep "^/" &> /dev/null
			if [ $? -eq 0 ]; then
				new_link="$(protocol $1)://$(domain $1)$link"
				booleano=$(in_array $link "${arr[@]}" && echo yes || echo no)
				if [ $booleano == "no" ]; then
					arr=("${arr[@]}" $new_link)
					echo $new_link
					obtain_urls $new_link
				fi
			fi
		fi
	done
}


if [ $# -ne 1 ]; then
	echo "usage: bash $0 http://target.lul"
else
	curl -I $1 &> /dev/null
	if [ $? -eq 0 ]; then
		echo $1 | egrep "https?://" &> /dev/null
		if [ $? -eq 0 ]; then
			obtain_urls $1
		else
			echo "please add protocol http:// or https://"
		fi
	else
		echo "[-] Problems with connect to $1"
	fi
fi

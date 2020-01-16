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
	for link in $(curl -s $1 | pup 'a attr{href}' | sort -u); do
		if [[ $link != "EOF" ]]; then 
			echo $link | egrep "https?://" | grep $domain_url &> /dev/null
			if [ $? -eq 0 ]; then
				new_link=$link
				if [ ! -z $new_link ]; then
					booleano=$(in_array $new_link "${arr[@]}" && echo yes || echo no)
					if [ $booleano == "no" ]; then
						arr=("${arr[@]}" $new_link)
						echo $link
						obtain_urls $link
					fi
				fi
			else
				echo $link | egrep "^//" &> /dev/null
				if [ $? -eq 0 ]; then
					if echo $link | grep $domain_url &> /dev/null ; then
						new_link="$(protocol $1):$link"
						booleano=$(in_array $new_link "${arr[@]}" && echo yes || echo no)
						if [ $booleano == "no" ]; then
							arr=("${arr[@]}" $new_link)
							echo $new_link
							obtain_urls $new_link
						fi
					fi
				else
					echo $link | egrep "^/" &> /dev/null
					if [ $? -eq 0 ]; then
						new_link="$(protocol $1)://$(domain $1)$link"
						booleano=$(in_array $new_link "${arr[@]}" && echo yes || echo no)
						if [ $booleano == "no" ]; then
							arr=("${arr[@]}" $new_link)
							echo $new_link
							obtain_urls $new_link
						fi
					fi
				fi
			fi
		fi
	done
}


if [ $# -ne 1 ]; then
	echo "usage: bash $0 http://target.lul"
else
	echo $1 | egrep "https?://" &> /dev/null
	if [ $? -eq 0 ]; then
		domain_url=$(domain $1)
		curl -I $1 &> /dev/null
		if [ $? -eq 0 ]; then
			obtain_urls $1
		else
			echo "[-] Problems with connect to $1"
		fi
	else
		echo "please add protocol http:// or https://"
	fi
fi

#!/bin/bash

_version="0.0.0"

configomat_do_work() {
	echo -e "\nStarting to do overrides:"

	declare -A config_overrides

	_env_variable_prefix=$1
	[ -z ${_env_variable_prefix} ] && \
    echo "I could not find the env prefix. Exiting ..." && \
	return 1

	IFS=" " read -r -a _config_files <<< $2

	_tmpf=$(mktemp /tmp/configomat.XXXXXX) || exit 1

	printenv | grep $_env_variable_prefix > $_tmpf

	# dispatch env variables
	# for env_variable in $(printenv | grep $_env_variable_prefix);do
	while read env_variable
	do
		# get key
		# IFS not working because values like ldap_query_filter or search base consists of several '='
		# IFS="=" read -r -a __values <<< $env_variable
		# key="${__values[0]}"
		# value="${__values[1]}"
		key="$(echo $env_variable | cut -d '=' -f1)"
		key=${key#"${_env_variable_prefix}"}
		# make key lowercase
		key=${key,,}
		# get value
		value="$(echo $env_variable | cut -d '=' -f2-)"
		config_overrides[$key]="$value"
	done <$_tmpf

	rm -f $_tmpf

	for f in "${_config_files[@]}"
	do
		if [ ! -f "${f}" ];then
			echo "Can not find ${f}. Skipping override"
		else
			for key in ${!config_overrides[@]}
			do
				[ -z $key ] && echo -e "\t no key provided" && return 1

				echo "  >> $f: $key = ${config_overrides[$key]}"

				# Escape special characters
				config_overrides[$key]="$((echo ${config_overrides[$key]}|sed -r 's/([\=\&\|\$\.\*\/\[\\^])/\\\1/g'|sed 's/[]]/\\]/g')>&1)"

				sed -i -e "s|^${key}[[:space:]]\+.*|${key} = ${config_overrides[$key]}|g" \
				${f}

			done
		fi
	done
  return 0
}

echo -e "\nConfig'O'mat. Version $_version"

# Initial Checks
[[ "$#" -ne 2 ]] && echo "I need two arguments: Env prefix (e.g. CONFIGOMAT_) and " \
                         "the file to parse. Exiting ..." && exit 1

[[ ! -f "$2" ]] && echo "The file could not be found: $2. Exiting ..." && exit 1

echo "-------------------"
echo "Got the ENV_PREFIX: $1"
echo "Got the CONF_FILE:  $2"
echo "-------------------"

configomat_do_work $1 $2
exit $?
#!/bin/bash

USAGE="Install or update vim plugin from github

see http://github.com/tpope/vim-pathogen

USAGE:
	$0 <github name> [<bundle name> [<github branch>]]

	github name - without git suffix
	bundle name - default to basename github_name
	github branch - default to master

EXAMPLE:
	bash $0 kchmck/vim-coffee-script
	bash $0 kchmck/vim-coffee-script vim-coffee-script
	bash $0 kchmck/vim-coffee-script vim-coffee-script master
"


usage() {
	echo "$USAGE"
	exit 2
}

github_name="$1"
bundle_name=${2:-$(basename "$github_name")}
github_branch=${3:-master}


test -z "$1" -o "$1" = '-h' && usage

message="bundle/$bundle_name from github $github_name $github_branch

from https://github.com/$github_name

Install or update

	bash github-plugin-install.sh $github_name $bundle_name $github_branch
"

if test -d bundle/$bundle_name
then
	cmd=pull
	action=Update
else
	cmd=add
	action=Add
fi

echo "$action $github_name"
git subtree $cmd \
	--prefix=bundle/$bundle_name \
	--squash \
	-m "$action $message" \
	https://github.com/$github_name.git $github_branch

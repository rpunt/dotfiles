#!/bin/bash

# https://austincloud.guru/2018/11/27/1password-cli-tricks/

oplogin() {
  eval $(op signin puntfamily --session "$OP_SESSION_puntfamily")
}

# function adminpassupdate() {
#   password="${1}"
#   # echo "$password" | od -c
#   op get account 1>/dev/null 2>&1 || oplogin
#   op edit item "ITEM NAME" password=$(echo "$password"|tr '\n' ' ')
# }

oplogoff() {
  op signout
}

getpassword() {
  oplogin
  op get item "$1" |jq -r '.details.fields[] |select(.designation=="password").value'
}

#######
### evaluate these for further use
#
#sshkey() {
#  op get account 1>/dev/null 2>&1 || oplogin
#  echo "$(op get item "acg-master" |jq -r '.details.notesPlain')"|ssh-add -
#}
#
#gittoken() {
#  # opon
#  op get account 1>/dev/null 2>&1 || oplogin
#  export GIT_TOKEN=$(op get item "GitHub"|jq -r '.details.sections[] | select(.fields).fields[] | select(.t== "Personal Laptop").v')
#}

getmfa() {
  oplogin
  op get totp "$1"
}

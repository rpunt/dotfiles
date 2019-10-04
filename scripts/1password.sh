#!/bin/bash

# https://austincloud.guru/2018/11/1password-cli-tricks/

opon() {
  if [[ -z $OP_SESSION_puntfamily ]]; then
    eval $(op signin puntfamily)
  fi
}

opoff() {
  op signout
  unset OP_SESSION_puntfamily
}

getpwd() {
  opon
  op get item "$1" |jq -r '.details.fields[] |select(.designation=="password").value'
  opoff
}

# evaluate these for further use
#sshkey() {
#  opon
#  echo "$(op get item "acg-master" |jq -r '.details.notesPlain')"|ssh-add -
#  opoff
#}
#gittoken() {
#  opon
#  export GIT_TOKEN=$(op get item "GitHub"|jq -r '.details.sections[] | select(.fields).fields[] | select(.t== "Personal Laptop").v')
#  opoff
#}

getmfa() {
  opon
  op get totp "$1"
  opoff
}

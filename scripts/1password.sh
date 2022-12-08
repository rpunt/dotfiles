# https://austincloud.guru/2018/11/27/1password-cli-tricks/

oplogin() {
  op account get 1>/dev/null 2>&1
  retVal=$?
  if [ $retVal -ne 0 ]; then
    eval "$(op signin --account puntfamily)"
  fi
}

# function adminpassupdate() {
#   read -r password <<< "${1}"
#   oplogin
#   op item edit "1password entry" password="$(echo "$password"|tr '[:space:]' ' ')"
# }

oplogoff() {
  op signout --all
}

getpassword() {
  oplogin
  op item get "$1" --format json | jq -r '.fields[] | select(.id=="password").value'
}

gettoken() {
  oplogin
  op item get "$1" --format json | jq -r '.fields[] | select(.label=="token").value'
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
  op item get "$1" --format json | jq -r '.fields[] | select(.type=="OTP").totp'
}

# # to enable 1password shell plugins, configure them and uncomment this:
# source "$HOME/.config/op/plugins.sh"

auth_gh_work() {
  oplogin
  tokenfile=$(mktemp)
  gettoken "gh work pat" >"$tokenfile"
  gh auth login --git-protocol ssh --with-token < "$tokenfile"
  rm -f "$tokenfile"
}

auth_gh_home() {
  oplogin
  tokenfile=$(mktemp)
  gettoken "gh personal pat" >"$tokenfile"
  gh auth login --git-protocol https --with-token < "$tokenfile"
  rm -f "$tokenfile"
}

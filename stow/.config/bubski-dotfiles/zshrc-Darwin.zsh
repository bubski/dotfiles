alias s='/Applications/Sublime\ Text.app/Contents/SharedSupport/bin/subl'
alias hop='hopperv4 -e'
alias glog="git log --graph --pretty=format:'%Cgreen%ad%Creset %C(auto)%h%d %s %C(bold black)<%aN>%Creset' --date=format-local:'%Y-%m-%d %H:%M (%a)'"

export EDITOR='/Applications/Sublime\ Text.app/Contents/SharedSupport/bin/subl -nw'

function uncrustify-imports() {
  FOO=$(pbpaste | sort --ignore-case | uniq | grep -Ev "^$")
  printf "%s" "$FOO" | pbcopy
}

function cleanDesktop() {
  DATE_STRING=$(date "+%Y-%m-%d at %H-%M-%S")
  DIR=~/Documents/from\ Desktop/$DATE_STRING
  #echo $DIR
  mkdir -p $DIR
  mv ~/Desktop/* $DIR/
}

function note() {
  DATE_STRING=$(date "+%Y-%m-%d at %H-%M-%S")
  mkdir -p ~/Documents/Notes
  FILE_PATH=~/Documents/Notes/$DATE_STRING.txt
  echo $FILE_PATH
  touch $FILE_PATH
  open -a /Applications/Sublime\ Text.app "$FILE_PATH"
}

function jsonote () {
  DATE_STRING=$(date "+%Y-%m-%d at %H-%M-%S")
  FILE_PATH=~/Documents/Notes/$DATE_STRING.json
  echo $FILE_PATH
  touch $FILE_PATH
  open -a /Applications/Sublime\ Text.app "$FILE_PATH"
}

function nukeXcodeCaches() {
  rm -fr ~/Library/Developer/Xcode/DerivedData
  rm -fr ~/Library/Caches/com.apple.dt.Xcode
  rm -fr ~/Library/Caches/com.apple.dt.Xcode.sourcecontrol.Git
}

function nukeVulcan() {
  rm -fr ~/.vulcan
}

function killXcode() {
  if pgrep Xcode > /dev/null; then killall Xcode; fi
}

function gitBranchesByCommitDate() {
  git branch --sort=-committerdate
}

function gitPushCurrentBranch() {
  git push -u bubski $(git rev-parse --abbrev-ref HEAD)
}

function gifmeup() {
  if [ ! -z $1 ]; then
    if [ -f "$1" ]; then
      OUT_FILE_NAME="$1.gif"
      if [ -f "$1" ]; then
        n=1; while [ -f "$1-$n.gif" ]; do ((++n)); done; OUT_FILE_NAME="$1-$n.gif"
      fi
      echo $OUT_FILE_NAME
      gifenc -f 30 -w 320 -i "$1" -o "$OUT_FILE_NAME"
    else
      echo "No file named $1" >&2
    fi
  else
    echo "Missing file name" >&2
  fi
}

checkout-pr () {
  if [ -z "$1" ]
  then
    echo "missing PR number"
    return 1
  fi
  if [[ -n $(git status --short --ignore-submodules) ]]
  then
    echo "git status not clean"
    return 1
  fi
  REF_NAME="pull/$1/head"
  git fetch iOS "$REF_NAME" && git checkout FETCH_HEAD
}

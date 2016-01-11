#GET BASE PATH- ---------------------------------
SOURCE="${BASH_SOURCE[0]}"
while [ -h "$SOURCE" ]; do # resolve $SOURCE until the file is no longer a symlink
  DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"
  SOURCE="$(readlink "$SOURCE")"
  [[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE" # if $SOURCE was a relative symlink, we need to resolve it relative to the path where the symlink file was located
done

export DOTFILES="$(dirname "$SOURCE")"

#INCLUDED SOURCES -------------------------------

source "${DOTFILES}/bash/external/user.sh"
source /opt/boxen/env.sh
source "${DOTFILES}/bash/helpers/docker.sh"
source "${DOTFILES}/bash/external/docker.sh"
source "${DOTFILES}/bash/helpers/squid_proxy.sh"
source "${DOTFILES}/bash/colors.sh"
source "${DOTFILES}/bash/environment.sh"
source "${DOTFILES}/bash/completion.sh"
source "${DOTFILES}/bash/aliases.sh"
source "${DOTFILES}/bash/prompt.sh"
source "${DOTFILES}/bash/external/proxy.sh"

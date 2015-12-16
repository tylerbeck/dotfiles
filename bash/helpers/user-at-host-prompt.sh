__user_at_host_ps1 ()
{
	if [ "$USER" = "{user}" ] &&
	   [ $(hostname -fs) = "{host}" ]; then
		printf "•"
	elif [ "$USER" = "root" ] &&
	   		[ $(hostname -fs) = "{host}" ]; then
		printf "root"
	else
		printf "$USER@$(hostname -fs)"
	fi
}

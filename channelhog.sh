	install)
		Check_Lock "$@"
		while true; do
			echo "Would You Like To Enable Discord Notifications?"
			echo "[1]  --> Yes"
			echo "[2]  --> No"
			echo
			echo "[e]  --> Exit Menu"
			echo
			echo "Please Select Option"
			printf "[1-2]: "
			read -r "menu1"
			echo
			case "$menu1" in
				1)
					while true; do
						echo "Please Enter Discord Channel Webhook URL"
						printf "[URL]: "
						read -r "webhookurl"
						echo
						if [ "$webhookurl" = "e" ]; then
							echo "[*] Exiting!"
							echo; exit 0
						fi
						if ! curl -sI "$webhookurl" | grep -qE "HTTP/1.[01] [23].." || ! curl -s "$webhookurl" | grep -qF "token"; then
							echo "[*] $webhookurl Isn't A Valid URL!"
							echo
							continue
						fi
						enablediscord="true"
						break
					done
					break
				;;
				2)
					echo "[i] Discord Notifications Disabled"
					enablediscord="false"
					break
				;;
				e|exit)
					echo "[*] Exiting!"
					echo; exit 0
				;;
				*)
					echo "[*] $menu1 Isn't An Option!"
					echo
				;;
			esac
		done
		if [ ! -f "/jffs/scripts/init-start" ]; then
			echo "#!/bin/sh" > /jffs/scripts/init-start
			echo >> /jffs/scripts/init-start
		elif [ -f "/jffs/scripts/init-start" ] && ! head -1 /jffs/scripts/init-start | grep -qE "^#!/bin/sh"; then
			sed -i '1s~^~#!/bin/sh\n~' /jffs/scripts/init-start
		fi
		cmdline="sh /jffs/addons/channelhog/channelhog.sh start # ChannelHog"
		if grep -qE "^$cmdline" /jffs/scripts/init-start; then
			sed -i "s~^sh /jffs/addons/channelhog/channelhog.sh .* # ChannelHog~$cmdline~" /jffs/scripts/init-start
		else
			echo "$cmdline" >> /jffs/scripts/init-start
		fi
		chmod 755 "/jffs/scripts/init-start" "/jffs/addons/channelhog/channelhog.sh"
		if [ -d "/opt/bin" ] && [ ! -L "/opt/bin/channelhog" ]; then
			ln -s /jffs/addons/channelhog/channelhog.sh /opt/bin/channelhog
		fi
		Unload_Cron
		Load_Cron
		Write_Config
		if [ "$(nvram get wl1_bw)" != "5" ]; then
			nvram set wl1_bw=5
			echo "[i] Restarting 5GHz Radio To Complete Installation"
			printf "[i] Press Enter To Continue..."; read -r "continue"
			wl -i "$port5ghz1" down
			wl -i "$port5ghz1" up
			if [ -n "$port5ghz2" ]; then
				wl -i "$port5ghz2" down
				wl -i "$port5ghz2" up
			fi
		fi
	;;

	uninstall)
		Check_Lock "$@"
		echo "If You Were Experiencing Issues, Visit SNBForums/GitHub For Support"
		echo "https://github.com/Adamm00/ChannelHog"
		echo
		while true; do
			echo "[!] Warning - This Will Delete All ChannelHog Related Files"
			echo "Are You Sure You Want To Uninstall?"
			echo
			echo "[1]  --> Yes"
			echo "[2]  --> No"
			echo
			echo "Please Select Option"
			printf "[1-2]: "
			read -r "continue"
			echo
			case "$continue" in
				1)
					echo "[i] Deleting ChannelHog Files"
					sed -i '\~# ChannelHog~d' /jffs/scripts/init-start /jffs/configs/profile.add
					rm -rf "/jffs/addons/channelhog" "/opt/bin/channelhog"
					echo "[i] Complete!"
					echo
					exit 0
				;;
				2|e|exit)
					echo "[*] Exiting!"
					echo; exit 0
				;;
				*)
					echo "[*] $continue Isn't An Option!"
					echo
				;;
			esac
		done
	;;

	*)
		echo "Command Not Recognized, Please Try Again"
		echo "Accepted Commands Are; (sh $0 [start|check|disable|install|uninstall])"
		echo; exit 2
	;;
esac
if [ "$lockchannelhog" = "true" ]; then rm -rf "/tmp/channelhog.lock"; fi
echo
if [ -n "$reloadmenu" ]; then echo; printf "[i] Press Enter To Continue..."; read -r "continue"; exec "$0"; fi

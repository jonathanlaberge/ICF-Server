#!/bin/bash

### BEGIN INIT INFO
# Provides:          tf2server
# Required-Start:    $remote_fs
# Required-Stop:     $remote_fs
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: Team Fortress 2 server
# Description:       Starts a Team Fortress 2 server
### END INIT INFO

NAME="Team Fortress 2 CTF PL"
USER="serveur"
SCREENREF="tf2_ctf_pl"
BINARYPATH="/Jonathan/steam_serveur/tf2"
BINARYNAME="srcds_run"
PIDFILE="tf2_ctf_pl.pid"

OPTS="-echo $SCREENREF -game tf +ip 0.0.0.0 +map plr_highertower +sv_lan 0 -nohltv -port 27043 +clientport 27143 +sv_pure 0 +heartbeat +maxplayers 32 -authkey XXXX +servercfgfile server_ctf_pl.cfg +sm_basepath addons/sourcemod_ctf_pl"

cd "$BINARYPATH"
if [ ! "$USER" == "$(whoami)" ]; then
    su $USER -l
fi
running() 
{
    if [ ! -f $PIDFILE ]; then
        return 1
    else
        return 0
    fi
}

start() 
{
    if ! running; then
        echo -e -n "\e[97mStarting the $NAME server... \e[0m"
        screen -d -m -S $SCREENREF $BINARYPATH/$BINARYNAME $OPTS
        pgrep -f "$BINARYNAME -echo $SCREENREF" > $PIDFILE
        if [ -s $PIDFILE ]; then
            echo -e "\e[92mDone\e[0m"
        else
            echo -e "\e[91mFailed\e[0m"
            rm $PIDFILE
        fi
    else
        echo -e "\e[91mThe $NAME server is already started.\e[0m"
    fi
}

startnoscreen() 
{
    $BINARYPATH/$BINARYNAME $OPTS
}

stop() 
{
    if running; then
        echo -e -n "\e[97mStopping the $NAME server... \e[0m"
		kill `screen -ls |grep $SCREENREF |awk -F . '{print $1}'|awk '{print $1}'`
        rm $PIDFILE
        echo -e "\e[92mDone\e[0m"
    else
        echo -e "\e[91mThe $NAME server is already stopped.\e[0m"
    fi
}

case "$1" in
    start)
        start
    ;;
    startnoscreen)
        startnoscreen
    ;;
    stop)
        stop
    ;;
    restart)
	stop
        start
    ;;
    status)
        if running; then
            echo -e "\e[97m\e[2m$NAME\e[0m\e[97m server is \e[92mstarted\e[0m"
        else
            echo -e "\e[97m\e[2m$NAME\e[0m\e[97m server is \e[91mstopped\e[0m"
        fi
    ;;
    *)
        echo -e "\e[97mUsage: $0 (start|startnoscreen|stop|restart|status)\e[0m"
        exit 1
esac
exit 0

#!/bin/sh

HOST="http://127.0.0.1";
CHAN_PREFIX="DDD";
MAX_CHAN=3;

PHONE_PREFIX="9972"
ATS_PREFIX="FFF";
MAX_ATS=3;

HTTP_USER="tgrad";
HTTP_PASS="tgrad123"

wget_post() {
	local POST_DATA=$@;
	wget -O - -q --user ${HTTP_USER} --password ${HTTP_PASS} "$HOST/sigma/index.php" --post-data "$POST_DATA";
}

create_ats() {
	local lATS_NAME=$1;
	local lATS_TYPE=$2;
	local lCURMIN=$3;
	local lCURMAX=$4;
	echo "Создаем АТС: $lATS_NAME ($lATS_TYPE) => $lCURMIN-$lCURMAX";
	res=`wget_post "handler=PHONES&action=phones_atsadd&ats_name=$lATS_NAME&ats_type=$lATS_TYPE&minnumber=$lCURMIN&maxnumber=$lCURMAX"`;
}


check_ats () {
	local ATS_NAME=$1;
	echo "Проверяем наличие АТС: $ATS_NAME";
	res=`wget_post "handler=PHONES&action=atseditform&param=$ATS_NAME" | grep disabled`;
	if [ "x$res" = "x" ]
	then
		echo "АТС $ATS_NAME не существует";
		return 0;
	else
		echo "АТС $ATS_NAME существует";
		return 1;
	fi
}

get_channel_id () {
	CHAN=$1;
	#a=`wget_post  "handler=ATS&action=ats4channel&param=" | perl -e 'while(<>){chomp; if (/\>'$CHAN'\</) {printf $_;$b=1} if(/INPUT name=incl/ && $b == 1) {print $_."\n"; $b=0}}' | sed -re 's/.*\>(.*)\<.*incl\[([0-9]+)\].*/\2/g'`;
	a=`wget_post  "handler=ATS&action=ats4channel&param=" | perl -e 'while(<>){chomp; if (/\>'$CHAN'\</) {$b=1} if(/INPUT name=incl\[([0-9]+)\]/ && $b == 1) {print $1; $b=0}}'`;
	printf "%s" $a;
}

check_channel () {
	local CHANNAME=$1;
	local res=`get_channel_id $CHANNAME`
	if [ "x$res" = "x" ]
	then
			echo "Канал $CHANNAME не существует";
			return 0;
	else
			echo "Канал $CHANNAME существует";
			return 1;
	fi
}


create_channel () {
	local CHAN_NAME=$1;
	local CHAN_TYPE=$2;
#	IPADDRESS="127.0.0.1";
	IPADDRESS=$3;
	PORT=$4;
	LOGIN=$5;
	PASS=$6

	if [ "x$CHAN_TYPE" = "xexport" ]
	then
		PARAMNAME1="FILENAME";
		PARAMVALUE1="log/%ats_name%.export";
		PARAMNAME2="FMT";
		PARAMVALUE2="%id%;%command%;%phonenumber%;{COMMENT}"
	elif [ "x$CHAN_TYPE" = "xshell" ]
	then
		PARAMVALUE1="1";
	fi
	res=`check_channel $CHAN_NAME`
	if [ $? -eq 1 ]
	then
		echo "Канал: $CHAN_NAME уже существует";
	else
		echo "Создаем Канал: $CHAN_NAME ($CHAN_TYPE)";
		res=`wget_post "handler=ATS&action=saveconnection&param=&ats_type=$CHAN_TYPE&name=$CHAN_NAME&ip=${IPADDRESS}&port=${PORT}&login=${LOGIN}&pass=${PASS}&paramname%5B1%5D=$PARAMNAME1&paramvalue%5B1%5D=$PARAMVALUE1&paramname%5B2%5D=$PARAMNAME2&paramvalue%5B2%5D=$PARAMVALUE2"`;
		return;
	fi
}

create_channel_name_type_ip_port () {
	local CHAN_NAME=$1;
	local CHAN_TYPE=$2;
	IPADDRESS=$3;
	PORT=$4;
	LOGIN="login";
	PASS="password"

	if [ "x$CHAN_TYPE" = "xexport" ]
	then
		PARAMNAME1="FILENAME";
		PARAMVALUE1="log/%ats_name%.export";
		PARAMNAME2="FMT";
		PARAMVALUE2="%id%;%command%;%phonenumber%;{COMMENT}"
	elif [ "x$CHAN_TYPE" = "xshell" ]
	then
		PARAMVALUE1="1";
	fi
	res=`check_channel $CHAN_NAME`
	if [ $? -eq 1 ]
	then
		echo "Канал: $CHAN_NAME уже существует";
	else
		echo "Создаем Канал: $CHAN_NAME ($CHAN_TYPE)";
		res=`wget_post "handler=ATS&action=saveconnection&param=&ats_type=$CHAN_TYPE&name=$CHAN_NAME&ip=${IPADDRESS}&port=${PORT}&login=${LOGIN}&pass=${PASS}&paramname%5B1%5D=$PARAMNAME1&paramvalue%5B1%5D=$PARAMVALUE1&paramname%5B2%5D=$PARAMNAME2&paramvalue%5B2%5D=$PARAMVALUE2"`;
		return;
	fi
}


create_channel_dslam () {
	local CHAN_NAME=$1;
	local CHAN_TYPE=$2;
#	IPADDRESS="127.0.0.1";
	IPADDRESS=$3;
	PORT=$4;
	LOGIN="uik";
	PASS="uik!uik"

	if [ "x$CHAN_TYPE" = "xexport" ]
	then
		PARAMNAME1="FILENAME";
		PARAMVALUE1="log/%ats_name%.export";
		PARAMNAME2="FMT";
		PARAMVALUE2="%id%;%command%;%phonenumber%;{COMMENT}"
	elif [ "x$CHAN_TYPE" = "xshell" ]
	then
		PARAMVALUE1="1";
	fi
	res=`check_channel $CHAN_NAME`
	if [ $? -eq 1 ]
	then
		echo "Канал: $CHAN_NAME уже существует";
	else
		echo "Создаем Канал: $CHAN_NAME ($CHAN_TYPE)";
		res=`wget_post "handler=ATS&action=saveconnection&param=&ats_type=$CHAN_TYPE&name=$CHAN_NAME&ip=${IPADDRESS}&port=${PORT}&login=${LOGIN}&pass=${PASS}&paramname%5B1%5D=$PARAMNAME1&paramvalue%5B1%5D=$PARAMVALUE1&paramname%5B2%5D=$PARAMNAME2&paramvalue%5B2%5D=$PARAMVALUE2"`;
		return;
	fi
}


create_channel_tesla () {
	local CHAN_NAME=$1;
	local CHAN_TYPE=$2;
#	IPADDRESS="127.0.0.1";
	IPADDRESS=$3;
	PORT="8888";
	LOGIN="XXX";
	PASS="XXX"

	PARAMNAME1="TESLA_SESSION";
	PARAMVALUE1=$5;
	PARAMNAME2="TESLA_ATS"
	PARAMVALUE2=$4;

	res=`check_channel $CHAN_NAME`
	if [ $? -eq 1 ]
	then
		echo "Канал: $CHAN_NAME уже существует";
	else
		echo "Создаем Канал: $CHAN_NAME ($CHAN_TYPE)";
#		res=`wget_post "handler=ATS&action=saveconnection&param=&ats_type=$CHAN_TYPE&name=$CHAN_NAME&ip=${IPADDRESS}&port=${PORT}&login=${LOGIN}&pass=${PASS}&paramname%5B1%5D=$PARAMNAME1&paramvalue%5B1%5D=$PARAMVALUE1&paramname%5B2%5D=$PARAMNAME2&paramvalue%5B2%5D=$PARAMVALUE2"`;
		res=`wget_post "handler=ATS&action=saveconnection&param=&ats_type=$CHAN_TYPE&name=$CHAN_NAME&ip=${IPADDRESS}&port=${PORT}&login=${LOGIN}&pass=${PASS}&paramname1=$PARAMNAME1&paramvalue1=$PARAMVALUE1&paramname2=$PARAMNAME2&paramvalue2=$PARAMVALUE2"`;
		return;
	fi
}



clink()  {
	local ATS=$1;
	local CHANNAME=$2
	local CHANID=`get_channel_id $CHANNAME`;
	check_ats $ATS;
	if [ $? -eq 1 ]
	then
		echo "ATS exits";
	else
			echo "Не могу привязать канал $CHANNAME к АТС $ATS. АТС $ATS не существует";
		return;
	fi
	if [ "x$CHANID" != "x" ]
	then
		echo "Привязываю канал $CHANNAME к АТС $ATS";
		a=`wget_post "handler=ATS&action=save4channel&atsname=$ATS&incl%5B$CHANID%5D=on"`;
	else
		echo "Не могу привязать канал $CHANNAME к АТС $ATS. Канал $CHANNAME не сущестует";
	fi
}

clinks()  {
	local ATS=$1;
	shift;
	CHANS=$*;
	check_ats $ATS;
	if [ $? -eq 1 ]
	then
		echo "ATS exits";
	else
			echo "Не могу привязать канал $CHANS к АТС $ATS. АТС $ATS не существует";
		return;
	fi
	echo "Привязываем к $ATS следующие каналы $CHANS";
	local param="";
	local chan_list="";
	for CHANNAME in $CHANS
	do
			CHANID=`get_channel_id $CHANNAME`;
		if [ "x$CHANID" != "x" ]
		then
			echo "Выделяю в списке канал: $CHANNAME";
			param="$param&incl%5B${CHANID}%5D=on"
			chan_list="$chan_list,$CHANNAME($CHANID)";
				else
				echo "Не могу привязать канал $CHANNAME к АТС $ATS. Канал $CHANNAME не сущестует";
				fi
	done
	echo "Осуществляю привязку к $ATS следующих каналов $chan_list";
	a=`wget_post "handler=ATS&action=save4channel&atsname=$ATS&$param"`;
}

enable_channel() {
	local CHANNAME=$1;
	local CHANID=`get_channel_id $CHANNAME`;
	if [ "x$CHANID" != "x" ]
	then
			echo "Включаю канал $CHANNAME"
		a=`wget_post "handler=ATS&action=enable&param=$CHANID"`;
		else
			echo "Не могу включить канал $CHANNAME, так как он не сущестует"
		fi
}

get_command_id () {
	CHAN_TYPE=$2;
		COMMAND_NAME=$1;
	a=`wget_post  "handler=CMD&action=listcommands&ats_type=$CHAN_TYPE" | perl -e 'while(<>){chomp; if (/([0-9]+).,.*\Q'${COMMAND_NAME}'\E\?/) {printf $1;}}'`;
	echo $a;
}


deny_command () {
	local CHANNAME=$1
	local CHANID=`get_channel_id $CHANNAME`;
	local ATS_COMMAND_ID=`get_command_id $2 $3`;
	local ATS_COMMAND=$2;
	local ATS_TYPE=$3;

		if [ "x$ATS_COMMAND_ID" = "x" ]
	then
		echo "Не могу разрешить команду $ATS_COMMAND. Команда не определена для данного типа АТС";
		return;
	fi
	if [ "x$CHANID" != "x" ]
	then
		a=`wget_post "handler=CMD&action=deny&ats_id=${CHANID}&deny%5B${ATS_COMMAND_ID}%5D=on&id%5B${ATS_COMMAND_ID}%5D=${ATS_COMMAND_ID}&name%5B${ATS_COMMAND_ID}%5D=${ATS_COMMAND}"`;
	else
		echo "Не могу разрешить команду для канал $CHANNAME. Канал не существует";
	fi
}


deny_commands () {
	local CHANNAME=$1
	local CHANID=`get_channel_id $CHANNAME`;
	local ATS_TYPE=$2;
	shift; shift;
	ATS_COMMANDS=$*;
	echo "Разрешаем на  $CHANNAME следующие команды $ATS_COMMANDS";
	local param="";
	local comm_list="";
	for COMM in $ATS_COMMANDS
	do
		COMM_ID=`get_command_id $COMM $ATS_TYPE`;
			if [ "x$COMM_ID" != "x" ]
		then
			echo "Выделяю в списке команду: $COMM";
			param="$param&deny%5B${COMM_ID}%5D=on&name%5B${COMM_ID}%5D=${COMM}&id%5B${COMM_ID}%5D=${COMM_ID}";
			comm_list="$comm_list,$COMM($COMM_ID)";
				else
			echo "Не могу разрешить команду $COMM. Команда не определена для данного типа АТС";
				fi
	done
	echo "Осуществляю разрешение на канале $CHANNAME следующих команд $comm_list";
	a=`wget_post "handler=CMD&action=deny&ats_id=${CHANID}&$param"`;
}



deny_command_export () {
	deny_command $1 'export' '\*';
}

deny_command_shell () {
	deny_commands $1 'shell' 'LOGOUT' 'DATE' 'ECHO' 'LINE_MEASURE';
}


deny_command_dhttp () {
	deny_commands $1 '' 'PMS_ADD' 'TONE_VIEW';
}

deny_command_dslam () {
	deny_commands $1 'dslama5600' 'DSLAM_MEASURE';
}

deny_command_tesla_auto () {
		deny_commands $1 'tesla'      \
		'LINE_MEASURE'   \
		'LINE_MEASURE2'  \
		'LINE_STATUS'    \
		'LINE_VIEW';

}

deny_command_tesla_all () {
		deny_commands $1 'tesla'      \
		'LINE_MEASURE'   \
		'LINE_MEASURE2'  \
		'LINE_STATUS'    \
		'LINE_VIEW'      \
		'LOCK'           \
		'MANUAL_15'      \
		'MANUAL_16'      \
		'MANUAL_17'      \
		'MANUAL_18'      \
		'MANUAL_19'      \
		'MANUAL_20'      \
		'MANUAL_21'      \
		'MANUAL_22'      \
		'MANUAL_23'      \
		'MANUAL_24'      \
		'MANUAL_25'      \
		'MANUAL_START'   \
		'RESET'          \
		'SESSION_CLOSE'  \
		'UNLOCK'         ;

}



###### TEST ##############



create_test_ats_list() {
	local ATS_TYPE="export";
	local i=0;
	while :
	do
		i=`expr $i + 1`;
		a=`printf "%03s\n" $i`;
		ATS_NAME=$ATS_PREFIX$a;
		echo $ATSNAME;
		min=$(expr $i \* 100)
		max=$(expr $min + 99)
		CURMIN=`printf "$PHONE_PREFIX%06s\n" $min`;
		CURMAX=`printf "$PHONE_PREFIX%06s\n" $max`;
#		echo $CURMIN-$CURMAX;
		create_ats $ATS_NAME $ATS_TYPE $CURMIN $CURMAX;
		if [ $i -eq $MAX_ATS ]
		then
			break;
		fi;
	done
}


create_test_channel_list () {
	local CHAN_TYPE="export";
	local i=0;
	while :
	do
		i=`expr $i + 1`;
		CHAN_NAME=`printf "$CHAN_PREFIX%03s" $i`;
		echo "Создаем $CHAN_NAME";
		create_channel $CHAN_NAME $CHAN_TYPE
				enable_channel $CHAN_NAME;
		if [ $i -eq $MAX_CHAN ]
		then
			break;
		fi;
	done
}


create_link_ats_to_chan () {
	clinks
}


create_test_10 () {
	local NAME=$1
	local MIN_PHONE=$2;
	local MAX_PHONE=$3
	local MAX_CHAN=$4;
	local gATS_TYPE=$5;
		local gCHAN_TYPE=$5;
	create_ats $NAME $gATS_TYPE $MIN_PHONE $MAX_PHONE
	listchan="";
	local i=0;
	while :
	do
		i=`expr $i + 1`;
		create_channel "$NAME:$i" $gCHAN_TYPE;
		enable_channel "$NAME:$i"
		if [ "x$gCHAN_TYPE" = "xexport" ]
		then
			deny_command_export "$NAME:$i"
		fi
		if [ "x$gCHAN_TYPE" = "xshell" ]
		then
			deny_command_shell "$NAME:$i"
		fi
		if [ "x$gCHAN_TYPE" = "xdhttp" ]
		then
			deny_command_dhttp "$NAME:$i"
		fi
		listchan="$listchan $NAME:$i"
		if [ $i -eq $MAX_CHAN ]
		then
			break;
		fi;
	done
	clinks $NAME $listchan
}

create_test_ats_EXPORT() {
	local lMAX_CHAN=$4
	local lMAX_ATS=$3;
	local lPHONE_PREFIX=$2;
	local lATS_PREFIX=$1
	local i=0;
	while :
	do
		i=`expr $i + 1`;
		a=`printf "%05s\n" $i`;
		ATS_NAME="$lATS_PREFIX$a";
		min=$(expr $i \* 100)
		max=$(expr $min + 99)
		CURMIN=`printf "${lPHONE_PREFIX}%06s\n" $min`;
		CURMAX=`printf "${lPHONE_PREFIX}%06s\n" $max`;
		create_test_10 $ATS_NAME $CURMIN $CURMAX $lMAX_CHAN "dhttp" "dhttp";
		if [ $i -eq $lMAX_ATS ]
		then
			break;
		fi;
	done
}


#create_test_ats_list;
#create_test_channel_list;

# create_test_ats_EXPORT  "TEST_DHTTP" 8881 2 2

# create_ats "test" dslama5600 0 0
# create_channel_dslam "test" "dslama5600" "172.22.0.100" "23"
# deny_command_dslam "test"
# enable_channel "test"
# clink "test" "test"
#get_command_id "export" "*"

#get_channel_id "UAD7_Brinskogo";
#exit;
. main.inc

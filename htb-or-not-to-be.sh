#!/bin/bash
###
# flags: -l (active, retired), 
#-i (machine info: with ), -s (sort: id,Difficulty, Name, OS)
#
#
##
target="https://www.hackthebox.eu/"
endpoint=""

trap ctrl_c INT


function get_machines() {

case $1 in
    active)
        endpoint="api/v4/machine/list"
        output="active_machines.json"
        ;;
    retired)
        endpoint="api/v4/machine/list/retired"
	    output="retired_machines.json"
        ;;
    *)
        ;;
esac


if [ -n $endpoint ]
then
    echo $target$endpoint
    machine_data=$(curl -s -H "Authorization: Bearer $ACCESS_TOKEN" -H "Accept: application/json" $target$endpoint -X GET -L )
else
    echo "not valid option"
fi



}

function print_list(){

    if [ $sort ]
    then

        case $sort in
            id) key="id";;
            level) key="level";;
            name) key="name";;
            os) key="os";;
            *) key="id";;
        esac

        if [ $sort == "level" ]    
        then
            echo $1 | jq ' .info[] 
| select(.difficultyText=="Easy").level |= 0
| select(.difficultyText=="Medium").level |= 1 
| select(.difficultyText=="Hard").level |= 2
| select(.difficultyText=="Insane").level |= 3
| "\(.id) \(.name) \(.difficultyText) \(.ip) \(.os) \(.authUserInRootOwns) \(.level)"' | sed -e 's/^"//' -e 's/"$//' | sort -k 7 | awk 'BEGIN { printf ("%s \t %8s \t %8s \t %8s \t %8s \t %8s \n", "ID" ,"Name", "Difficulty", "IP" , "OS", "authUserInRootOwns")} { printf("%s \t %8s \t %8s \t %8s \t %8s \t %8s \n", $1, $2, $3, $4, $5, $6) }'
        else
        echo $1 | jq '.info | sort_by(.'$key') [] | "\(.id) \(.name) \(.difficultyText) \(.ip) \(.os) \(.authUserInRootOwns)"' | sed -e 's/^"//' -e 's/"$//' | awk 'BEGIN { printf ("%s \t %8s \t %8s \t %8s \t %8s \t %8s \n", "ID" ,"Name", "Difficulty", "IP" , "OS", "authUserInRootOwns")} { printf("%s \t %8s \t %8s \t %8s \t %8s \t %8s \n", $1, $2, $3, $4, $5, $6) }'
        fi
    elif [ $os ]
    then
        echo "$os"
        echo $1 | jq '.info[]|select(.os=="'$os'") | "\(.id) \(.name) \(.difficultyText) \(.ip) \(.os) \(.authUserInRootOwns)"' | sed -e 's/^"//' -e 's/"$//' | awk 'BEGIN { printf ("%s \t %8s \t %8s \t %8s \t %8s \t %8s \n", "ID" ,"Name", "Difficulty", "IP" , "OS", "authUserInRootOwns")} { printf("%s \t %8s \t %8s \t %8s \t %8s \t %8s \n", $1, $2, $3, $4, $5, $6) }'
    else
        echo $1 | jq '.info[]| "\(.id) \(.name) \(.difficultyText) \(.ip) \(.os) \(.authUserInRootOwns)"' | sed -e 's/^"//' -e 's/"$//' | awk 'BEGIN { printf ("%s \t %8s \t %8s \t %8s \t %8s \t %8s \n", "ID" ,"Name", "Difficulty", "IP" , "OS", "authUserInRootOwns")} { printf("%s \t %8s \t %8s \t %8s \t %8s \t %8s \n", $1, $2, $3, $4, $5, $6) }'
    fi
    
    

}

function searchIdMachineByName(){
    
    echo $1

    get_machines active

    machine_id=$(echo $machine_data | jq '.info[] | select(.name=="'$1'") | (.id)')
    
    echo "id active: "$machine_id

    if [ $machine_id ]
    then
        echo ""
    else
        get_machines retired
        machine_id=$(echo $machine_data | jq '.info[] | select(.name=="'$1'") | (.id)')
        echo "id retired: "$machine_id

    fi

    
}

function play_machine(){
    #https://www.hackthebox.eu/api/v4/machine/play/344
    echo "https://www.hackthebox.eu/api/v4/machine/play/"$1 
    curl  -H "Authorization: Bearer $ACCESS_TOKEN" -H "Accept: application/json" https://www.hackthebox.eu/api/v4/machine/play/$1 -X POST -L 
}

function stop_machine(){
    #https://www.hackthebox.eu/api/v4/machine/play/344
    curl  -H "Authorization: Bearer $ACCESS_TOKEN" -H "Accept: application/json" https://www.hackthebox.eu/api/v4/machine/stop -X POST -L 
}



function download_data(){
    get_machines active
    echo $machine_data > $output
    get_machines retired
    echo $machine_data > $output
}

function htb_login(){
    read  -p 'Enter email: ' email
    read -s -p 'Enter password: ' password
    echo -e "\n"


    ACCESS_TOKEN=$(curl -s -H "Content-Type: application/json" -d '{"email": "'"$email"'", "password": "'"$password"'"}' -X POST https://www.hackthebox.eu/api/v4/login -L | jq -r '.message' | jq -r '.access_token')	

 
}


function dependencies(){
    array=( "figlet")
    for i in "${array[@]}"
    do
        command -v $i >/dev/null 2>&1 || { 
            echo >&2 "$i required"; 
            exit 1; 
        }
    done    
}

#htb_login

#download_data

#dependencies
#figlet -w 100 HTB or NOT to BE


#check options

FLAG_INFO=64
FLAG_LIST=16
FLAG_LIST_SORT=48
FLAG_LIST_OS=18
FLAG_LIST_SORT_OS=50
FLAG_PLAY_MACHINE=8
FLAG_STOP_MACHINE=4
FLAG_DOWNLOAD_DATA=1




function main(){
    echo "$@"
    FLAG_CHECK=0

    while getopts dh:i:l:p:sk:O: flag
    do
        case "${flag}" in
            d) d=true  && FLAG_CHECK=$(expr $FLAG_CHECK + 1) ;;
            i) info=${OPTARG} && FLAG_CHECK=$(expr $FLAG_CHECK + 64);;
            k) sort=${OPTARG} && FLAG_CHECK=$(expr $FLAG_CHECK + 32);;
            l) list=${OPTARG} && FLAG_CHECK=$(expr $FLAG_CHECK + 16);;
            p) play=${OPTARG} && FLAG_CHECK=$(expr $FLAG_CHECK + 8);;
            s) s=true && FLAG_CHECK=$(expr $FLAG_CHECK + 4);;
            O) os=${OPTARG} && FLAG_CHECK=$(expr $FLAG_CHECK + 2);;
            *);;
        esac
    done

    check $FLAG_CHECK

}

function check(){
    case $1 in
        $FLAG_INFO) 
            echo "INFO: not available yet" 

            ;;
        $FLAG_LIST)    
            echo "Get machine list" 
            htb_login
            get_machines $list
            print_list $machine_data
            ;;
        $FLAG_LIST_SORT)   
            echo "Get machines and sort: not available yet" 
            ;;
        $FLAG_LIST_OS) 
            echo "Get machines and select OS: not available yet" 
            ;;
        $FLAG_LIST_SORT_OS) 
            echo "Get machines, select OS and sort: not available yet" 
            ;;
        $FLAG_PLAY_MACHINE) 
            echo "PLAY MACHINE: not available yet" 
            ;;  
        $FLAG_STOP_MACHINE)     
            echo "STOP MACHINE: not available yet" 
            ;;
        $FLAG_DOWNLOAD_DATA) 
            echo "DOWNLOAD DATA: not available yet" 
            ;;
        *)
            echo "error"
            exit 1 
            ;;
    esac
}

main "$@"
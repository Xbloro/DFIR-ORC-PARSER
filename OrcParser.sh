################################################################################
############################" ORC PARSER"#######################################
################################################################################
#made by HRO
#this script parse the results of DFIR-ORC Tools
#It reads a configuration file to sort files

# ----------------------------------
# Colors
# ----------------------------------
NOCOLOR='\033[0m'
RED='\033[0;31m'
GREEN='\033[0;32m'
ORANGE='\033[0;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
LIGHTGRAY='\033[0;37m'
DARKGRAY='\033[1;30m'
LIGHTRED='\033[1;31m'
LIGHTGREEN='\033[1;32m'
YELLOW='\033[1;33m'
LIGHTBLUE='\033[1;34m'
LIGHTPURPLE='\033[1;35m'
LIGHTCYAN='\033[1;36m'
WHITE='\033[1;37m'


#caseName=$3
#mainPath=$2
#orcFolder=$1

caseName=$3
pathToMainWorkDir=$2
pathToOrcArchive=$1
#encryptedPath=$2
#privKeyPath=$3

#configFile="configuration/config.txt"
#on prepare les paths

temp="${mainPath: -1}"
if [ "$temp" != "/" ]; then
    mainPath=$mainPath"/"
fi

temp="${encryptedPath: -1}"
if [ "$temp" != "/" ]; then
    encryptedPath=$encryptedPath"/"
fi



function decrypt(){

    endFoler=$mainPath$(date +'%m-%d-%Y-%H:%M')"-OrcFiles/"
    orcFolder=$endFoler"ORC/"
    orcUnzippedFolder=$endFoler"ORCUnzipped/"
    orcToPlasoFolder=$endFoler"ORCToPlaso/"

    mkdir -p $endFoler   #/home/hro/Angolan/01-06-2021-OrcFiles
    mkdir -p $orcFolder
    mkdir -p $orcUnzippedFolder
    mkdir -p $orcToPlasoFolder

    7za x $encryptedPath"*.7z" -o$encryptedPath -aou #on dezip tout
    #rm $encryptedPath"*.7z" #on clean les archives traitées

    python3 ./orc-decrypt/orc-decrypt.py -k $privKeyPath $encryptedPath $orcFolder #on dechiffre vers le dossier ORC
    mv $mainPath"/DFIR-Orc*" $orcFolder
    parse

}

function initialise(){
    file=$pathToOrcArchive
    OrcArchiveFileNameWPath=${file%.*}
    OrcArchiveFileNameWExt=$(basename $file)
    OrcArchiveFileNameWOExt=$(basename $OrcArchiveFileNameWExt ".7z")
    OrcArchiveFileExt="${file#*.}"
    
    caseDir=$pathToMainWorkDir"/"$caseName
    mainWorkDir=$caseDir"/"$(date +'%m-%d-%Y-%H:%M')"-"$OrcArchiveFileNameWOExt
    extractedDir=$mainWorkDir"/extracted"
    parsedDir=$mainWorkDir"/parsed"

    eventsDir=$parsedDir"/events"
    eventsJsonDir=$eventsDir"/events-json"
    eventsParsed=$eventsDir"/events-parsed"

    processDir=$parsedDir"/process"
    netWorkDir=$parsedDir"/network"
    hiveDir=$parsedDir"/hives"
    mftDir=$parsedDir"/mft"
    artefactsDir=$parsedDir"/artefact"
    prefetchDir=$parsedDir"/prefetch"
    timelineDir=$parsedDir"/timeline"

    mkdir -p $caseDir
    mkdir -p $mainWorkDir
    mkdir -p $extractedDir
    mkdir -p $parsedDir

    mkdir -p $eventsJsonDir
    mkdir -p $eventsParsed
    mkdir -p $hiveDir
    mkdir -p $prefetchDir
    mkdir -p $timelineDir
    mkdir -p $processDir
    mkdir -p $artefactsDir
    mkdir -p $netWorkDir
    mkdir -p $mftDir


    echo "main work dir is :"$mainWorkDir
    echo "parsedDir is :"$extractedDir
    echo "extracted dir is :"$parsedDir

}

function extract_orc_archive(){
    if 7za x $file -o$extractedDir -aou;then
        echo -e "${GREEN}sucessfully unzipped ${NOCOLOR}"

        #On extract tout ce qui reste
        while [ $(find $extractedDir -name "*.7z" | wc -l) -ne 0 ]; do
            for endFile in $(find $extractedDir -name "*.7z");do
                outFolder=$(dirname $endFile)
                7za x $endFile  -o$outFolder -aou -p"avproof"
                rm -f $endFile
            done
        done
    
    else #si ça faill
        echo -e "${RED}failled unziping archive might be corrupted ${NOCOLOR}"
    fi   
}

function rename_all(){
    #On rename tout
    for fileToRename in $(find $extractedDir"/" -name "**_data");do
        mv "$fileToRename" "$(echo "$fileToRename" | sed s/_data//)"
    done
}

function move_no_parse(){
    find $extractedDir -iname "NTFSInfo_*" -exec cp {} $mftDir \;
    find $extractedDir -iname  "Enumlocs.txt" -exec cp {} $mftDir \;

    find $extractedDir -iname  "autoruns.csv" -exec cp {} $processDir \;
    find $extractedDir -iname  "Listdlls.txt" -exec cp {} $processDir \;
    find $extractedDir -iname  "processes1.csv" -exec cp {} $processDir \;
    find $extractedDir -iname  "processes2.csv" -exec cp {} $processDir \;
    find $extractedDir -iname  "handle.txt" -exec cp {} $processDir \;

    find $extractedDir -iname  "Tcpvcon.csv" -exec cp {} $netWorkDir \;
    find $extractedDir -iname  "netstat.txt" -exec cp {} $netWorkDir \;
    find $extractedDir -iname  "dns_cache.txt" -exec cp {} $netWorkDir \;
    find $extractedDir -iname  "BITS_jobs.txt" -exec cp {} $netWorkDir \;

    find $extractedDir -iname  "Systeminfo.csv" -exec cp {} $parsedDir \;
    

}

function convert_evtx_to_json(){
    #head -1 out.json | jq -r ".Event.EventData.SubjectUserName"
    find $extractedDir -type f -name "*.evtx" | while read fname; do
        echo  "$fname"
        eventFileNameWithPath=${fname%.*}
        eventFileNameWExt=$(basename $fname)
        eventFileNameWOExt=$(basename $eventFileNameWExt ".evtx")
        eventFileExt="${fname#*.}"
        ./outils/evtx_dump $fname >> $eventsJsonDir"/$eventFileNameWOExt.json"
        #./outils/evtx_dump -t $fname >> $eventsJsonDir"/$eventFileNameWOExt.json"
    done
}

function parse_system_hives(){
    find $extractedDir -type f -name "*_SOFTWARE" -exec regripper -r {} -aT -f software >> $hiveDir"/SOFTWARE" \;
    find $extractedDir -type f -name "*_SECURITY" -exec regripper -r {} -aT -f securityt >> $hiveDir"/SECURITY" \;
    find $extractedDir -type f -name "*_SYSTEM" -exec regripper -r {} -aT -f system >> $hiveDir"/SYSTEM" \;
    find $extractedDir -type f -iname "*_AMCACHE.hve" -exec regripper -r {} -aT -g >> $hiveDir"/AMCACHE" \;
}

function parse_user_hive(){
    find $extractedDir -type f -iname "*_NTUSER.DAT" | while read fname; do
        echo "parsing $fname"
        NtUserFileNameWithPath=${fname%.*}
        NtUserFileNameWExt=$(basename $fname)
        NtUserFileNameWOExt=$(basename $NtUserFileNameWExt ".evtx")
        NtUserFileExt="${fname#*.}"
        regripper -r $fname -aT -g >> $hiveDir"/"$NtUserFileNameWOExt
    done
    
}

function parse_prefetchs(){
    python3 ./outils/Windows-Prefetch-Parser/windowsprefetch/scripts/prefetch.py -f  --csv 

}

function plaso_all(){
    psteal.py --source $extractedDir -w $timelineDir"/timeline.csv"
}

function main(){
    #decrypt
    initialise
    extract_orc_archive
    rename_all
    move_no_parse
    convert_evtx_to_json
    parse_system_hives
    parse_user_hive
    #plaso_all
}

main


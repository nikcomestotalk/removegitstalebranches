#!/bin/sh
# Define your function here
repolink="/opt/repos.txt"
checkrepo() {
            if [ -f "$repolink" ]
            then
                listb=1
            else
                echo "No repos found, default path is /opt/repos.txt"
                exit 1
            fi
}
checkresult() {
    if [ $1 = "NO" ]
    then
        echo "No repos folder found"
        exit 1
    fi
}
remove_branch() {
    name=$1
    echo `git push origin --delete $name`
}
find_branches () {
    
    cd $1
    file="/opt/exclude_branches.txt"
    mergedbranches=`git branch -r --merged master | grep "origin/" | awk -F/ '{print $NF}'`
    olderbranches=`git for-each-ref --sort='-authordate:iso8601' --format=' %(authordate:relative)%09%(refname:short)'  |grep -e "[1|2|3|4|5|6|7|8|9|10] months ago" | grep "origin/" | awk -F/ '{print $NF}'`
    #outputs[0]=""
    find=0
    start=0
    
    if [ -f "$file" ]
    then
        excludebranches=`cat $file`
    else
        excludebranches=""
    fi
    for first in $mergedbranches
    do
        for second in $olderbranches
        do
            if [ "$first" = "$second" ]
            then
                find=1
                for third in $excludebranches
                do
                    if [ "$first" = "$third" ]
                    then
                        find=0
                    fi
                done
                break
            fi
        done
        if [ $find -eq 1 ]
        then
            start=`expr $start + 1`
            #start+=1
            echo $first
            #outputs="`expr $outputs[$start]=\"$first\"`"
            find=0
        fi
        
    done
    #echo $outputs
   #return outputs
   
}


case $1 in 
        
        list)
            checkrepo
            for repo in `cat $repolink`
            do
                data=`find_branches $repo`
                checkresult $data
                for i in $data
                do
                    echo $i
                done
            done    
        ;;
        remove)
            checkrepo
            data=`find_branches`
            checkresult $data
            for i in $data
            do
                remove_branch $i
            done
        ;;
    *)
    echo "Usage: gitstalebranches {list|remove}"
		exit 1
		;;
esac

exit 0

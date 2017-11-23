#!/bin/bash
#
# vim: ft=sh et ts=4 sw=4
#

set -ex 


cat << EOF > Dockerfile
FROM registry.docker-cn.com/library/busybox:1.27
ARG FILE_LOCATION 
COPY \${FILE_LOCATION} /var/file/backup.tar.gz
EOF

case $1 in
    "save")
    if [[ $# -le 2 ]]
    then
        echo "save <filelocation-foler> <docker-image-tag> [--push]"
        echo "example: save /tmp/test testnamespace/image:tag"
        exit
    else
        target=$2
        filename=$(uuidgen)
        filelocation=./${filename}.tar.gz
        tar zcvf $filelocation -C $target .
        docker build --build-arg FILE_LOCATION=$filelocation -t $3 .
        if [[ $4 == "--push" ]]
        then
            docker push $3
        else
            :
        fi
        rm $filelocation
    fi
    ;;
    "recover")
    if [[ $# -ne 3 ]]
    then
        echo "recover <docker-image-tag> <filelocation>"
        echo 'example: recover testnamespace/image:tag /tmp/test'
        exit
    else
        recoverlocation=$(pwd)/$3
        docker run --rm -v $recoverlocation:$recoverlocation $2 cp /var/file/backup.tar.gz $recoverlocation/
        cd $recoverlocation && tar -zxvf $recoverlocation/backup.tar.gz 
    fi
    ;;
    *)
    echo '''
Usage:

    save <filelocation> <docker-image-tag>
    recover <docker-image-tag> <filelocation> 
    '''
esac

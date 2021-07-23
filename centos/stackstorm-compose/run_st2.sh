#! /bin/bash



function stop_st2(){
    echo stop st2
    make down || error_exit 'could not stop st2'

}

function start_st2(){
    echo start st2
    make down || error_exit 'could not contact Docker daemon - please start docker'
    make up
    sleep 15
    init_auth_st2
    init_st2
}


function init_auth_st2(){
    echo initializing rbac
    sleep 10
    docker-compose exec stackstorm /bin/bash -c 'st2-apply-rbac-definitions --config-file=/etc/st2/st2.conf'
    cd $HOME_DIR
}

function docker_network(){
    echo "Check Docker Network"
    if [ ! "$(docker network ls | grep myprivate)" ]; then
        echo "Creating myprivate network ..."
        docker network create --subnet 10.1.1.0/24 myprivate
    else
        echo "myprivate network exists."
    fi
    if [ ! "$(docker network ls | grep mypublic)" ]; then
        echo "Creating mypublic network ..."
        docker network create --subnet 192.168.0.0/20 mypublic
    else
        echo "mypublic network exists."
    fi
}


function init_st2(){
    echo init st2

    docker-compose exec stackstorm /bin/bash -c 'st2ctl reload'

}




# Main



start=`date +%s`

docker_network
start_st2


end=`date +%s`
echo -- run time was $((end-start)) seconds.
echo -- stackstorm available at https://localhost

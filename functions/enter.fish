#!/usr/bin/env fish

function __enter_container_id -d "Enter container with provided id"
    set selected_container $argv
    if docker exec "$selected_container" bash >/dev/null
        docker exec -it "$selected_container" bash
    else
        docker exec -it "$selected_container" sh
    end
end

function __enter_select_container -d "Select container via fzf"
    docker ps --filter status=running --format "table {{.Names}}\t{{.Image}}\t{{.ID}}" | awk 'NR > 1 { print }' | sort | read -z containers
    if [ -z "$containers" ]
        echo -e "No running container found"
        return 1
    end
    printf $containers | fzf -e --reverse | awk '{ print $3 }' | read selected_container; or return 1
    printf $selected_container
end


function enter -d "Interactively try to enter a docker container"
    set selected_container (__enter_select_container); or return 1
    __enter_container_id $selected_container; or return 1
end

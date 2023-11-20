#!/bin/bash

api_server="127.0.0.1:10085"
data=$(xray api statsquery -s $api_server -pattern "")

print_traffic_info() {
    local name=$1
    local uplink=$(echo "$data" | jq --arg name "$name" -r '.stat[] | select(.name | test($name + ".*uplink")) | .value')
    local downlink=$(echo "$data" | jq --arg name "$name" -r '.stat[] | select(.name | test($name + ".*downlink")) | .value')

    local uplink_gb=$(awk "BEGIN { printf \"%.2f\", $uplink / 1024 / 1024 / 1024}")  
    local downlink_gb=$(awk "BEGIN { printf \"%.2f\", $downlink / 1024 / 1024 / 1024}")

    echo -e "$name \t 上传流量: $uplink_gb G"
    echo -e "$name \t 下载流量: $downlink_gb G"
}

check_jq_installed() {
    if ! [ -x "$(command -v jq)" ]; then 
        echo 'Error: jq is not installed, please install and retry.'
        read -p "jq is not installed. Do you want to install it? (y/n) " choice
        if [ "$choice" = "y" ]; then
            # 根据不同系统使用不同的包管理器安装jq
            if [ -x "$(command -v apt-get)" ]; then
                sudo apt-get update
                sudo apt-get install jq
            elif [ -x "$(command -v yum)" ]; then
                sudo yum install jq
            elif [ -x "$(command -v brew)" ]; then
                brew install jq
            else
                echo "Error: Cannot install jq. Please install it manually."
                exit 1
            fi
        else
            echo "jq installation cancelled."
            exit 1
        fi
    fi
}

main() {
    check_jq_installed

    # 获取所有用户的名称
    users=($(echo "$data" | jq -r '.stat[] | select(.name | test("^user>>>.+>>>traffic>>>uplink$")) | .name | split(">>>")[1]'))
    # 获取所有入口的名称
    inbounds=($(echo "$data" | jq -r '.stat[] | select(.name | test("^inbound>>>.+>>>traffic>>>uplink$")) | .name | split(">>>")[1]'))
    # 获取所有出口的名称
    outbounds=($(echo "$data" | jq -r '.stat[] | select(.name | test("^outbound>>>.+>>>traffic>>>uplink$")) | .name | split(">>>")[1]'))

    echo "========= 用户流量 ========="
    for user in "${users[@]}"
    do
        print_traffic_info "$user"
    done

    echo -e "\n========= 入口流量 ========="
    for inbound in "${inbounds[@]}"
    do
        print_traffic_info "$inbound"
    done

    echo -e "\n========= 出口流量 ========="
    for outbound in "${outbounds[@]}"
    do
        print_traffic_info "$outbound"
    done
}

main

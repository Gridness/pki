#!/bin/bash

set -e

function check_cluster_availability() {
    echo "Checking Kubernetes cluster availability"
}

function terraform() {

}

function apply_infra() {
    echo "Started infrastructure provisioning"
    check_cluster_availability
    terraform
}

function run() {
    apply_infra $@
}

run "$@" || exit 1

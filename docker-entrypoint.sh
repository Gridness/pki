#!/bin/bash

function check_cluster_availability() {
    echo "Checking Kubernetes cluster availability"
}

function apply_infra() {
    echo "Started infrastructure provisioning"
    check_cluster_availability
}

function run() {
    apply_infra $@
}

run "$@" || exit 1

// Copyright (c) 2020 Oracle and/or its affiliates.
// Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

output "network" { 
    value = { for segment in var.input.segments : segment.name => {
        name         = segment.name
        region       = var.input.region
        display_name = "${local.service_name}_${index(local.vcn_list, segment.name) + 1}"
        dns_label    = "${local.service_label}${index(local.vcn_list, segment.name) + 1}"
        compartment  = contains(flatten(var.input.domains[*].name), "network") ? "${local.service_name}_network_compartment" : local.service_name
        stage        = segment.stage
        cidr         = segment.cidr
        ipv6         = segment.ipv6
        gateways = {
            drg = {
                name     = "${local.service_name}_${index(local.vcn_list, segment.name) + 1}_drg"
                create   = anytrue([contains(local.routers[*].name, segment.name), contains(local.routers[*].name, "default")])
                type     = "VCN"
                cpe      = try(local.router_map[segment.name].cpe, local.router_map["default"].cpe)
                anywhere = try(local.router_map[segment.name].anywhere, local.router_map["default"].anywhere)
            }
            internet = {
                name   = "${local.service_name}_${index(local.vcn_list, segment.name) + 1}_internet"
                create = segment.internet == "ENABLE" ? true : false
            }
            nat = {
                name          = "${local.service_name}_${index(local.vcn_list, segment.name) + 1}_nat"
                create        = segment.nat == "ENABLE" ? true : false
                block_traffic = segment.nat == "DISABLE" ? true : false
            }
            osn = {
                name     = "${local.service_name}_${index(local.vcn_list, segment.name) + 1}_osn"
                create   = segment.osn != "DISABLE" ? true : false
                services = segment.osn == "ALL" ? "all" : "storage"
                all      = local.osn_cidrs.all
                storage  = local.osn_cidrs.storage
            }
        }
        subnets = {for subnet in local.subnets : subnet.name => {
            topology       = subnet.topology
            display_name   = "${local.service_name}_${index(local.vcn_list, segment.name) + 1}_${subnet.name}"
            cidr           = local.subnet_cidr[segment.name][subnet.name]
            dns_label      = "${local.service_label}${index(local.vcn_list, segment.name) + 1}${substr(subnet.name, 0, 3)}"
            #route_table    = "${local.service_name}_${index(local.vcn_list, segment.name) + 1}_${subnet.route}_route"
            #disable_nat    = subnet.disable_nat
        } if contains(segment.topology, subnet.topology)}
        security_lists = {for subnet in local.subnets : subnet.name => {
            display_name = "${local.service_name}_${index(local.vcn_list, segment.name) + 1}_${subnet.name}_firewall"
            tcp_ingress = [for firewall in local.firewalls : {for traffic in firewall.incoming : traffic.zone => {for port in traffic.ports: port => { 
                description = "Allow incoming ${port} traffic from the ${traffic.zone} to the ${firewall.name} tier"
                source      = matchkeys(values(local.zones[segment.name]), keys(local.zones[segment.name]), [traffic.zone])[0]
                stateless   = traffic.stateless
                min_port    = matchkeys(local.ports[*].min, local.ports[*].name, [port])[0]
                max_port    = matchkeys(local.ports[*].max, local.ports[*].name, [port])[0]
            }}} if firewall.name == subnet.firewall][0]
        } if contains(segment.topology, subnet.topology)}
        route_tables = {for route in local.routes: route.name => {
            display_name = "${local.service_name}_${index(local.vcn_list, segment.name) + 1}_${route.name}_route"
            route_rules  = {for destination in route.destinations: destination => {
                network_entity   = "${local.service_name}_${index(local.vcn_list, segment.name) + 1}_${route.gateway}"
                destination      = matchkeys(values(local.zones[segment.name]), keys(local.zones[segment.name]), [destination])[0]
                description      = "Routes ${route.name} traffic to ${destination} via the ${route.gateway} gateway as next hop"
            }} 
        }}
        security_zones = local.zones
    }if segment.stage <= local.lifecycle[var.input.stage]}
}
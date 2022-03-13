// Copyright (c) 2020 Oracle and/or its affiliates.
// Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

output "network" { 
  value = { for segment in var.resolve.segments : segment.name => {
    name         = segment.name
    region       = var.input.region
    display_name = "${local.service_name}_${index(local.vcn_list, segment.name) + 1}"
    dns_label    = "${local.service_label}${index(local.vcn_list, segment.name) + 1}"
    compartment  = contains(flatten(var.resolve.domains[*].name), "network") ? "${local.service_name}_network_compartment" : local.service_name
    stage        = segment.stage
    cidr         = segment.cidr
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
      }
        nat = {
        name          = "${local.service_name}_${index(local.vcn_list, segment.name) + 1}_nat"
      }
        osn = {
        name     = "${local.service_name}_${index(local.vcn_list, segment.name) + 1}_osn"
        services = var.input.osn == "ALL" ? "all" : "storage"
        all      = local.osn_cidrs.all
        storage  = local.osn_cidrs.storage
      }
    }
    route_table_input = [for destination in local.destinations: {
      name         = destination.name
      display_name = "${local.service_name}_${index(local.vcn_list, segment.name) + 1}_${destination.name}_route"
      gateway      = destination.gateway
      gateway_name = "${local.service_name}_${index(local.vcn_list, segment.name) + 1}_${destination.gateway}"
      destinations = zipmap(
        [for section in destination.sections: matchkeys(keys(local.zones[segment.name]), keys(local.zones[segment.name]), [section])[0]],
        [for section in destination.sections: matchkeys(values(local.zones[segment.name]), keys(local.zones[segment.name]), [section])[0]]   
      )
    }]
    security_groups = {for firewall in local.firewalls : firewall.name => { 
      display_name = "${local.service_name}_${index(local.vcn_list, segment.name) + 1}_${firewall.name}_host_firewall"
    }}
    security_lists = {for subnet in local.subnets : subnet.name => { 
      display_name = "${local.service_name}_${index(local.vcn_list, segment.name) + 1}_${subnet.name}_net_firewall"
      ingress      = {for traffic in local.firewall_map[subnet.firewall].incoming: "${traffic.firewall}_${traffic.zone}_${traffic.port}" => {
        protocol    = matchkeys(local.ports[*].protocol, local.ports[*].name, [traffic.port])[0]
        description = "Allow incoming ${traffic.port} traffic from the ${traffic.zone} to the ${traffic.firewall} tier"
        source      = matchkeys(values(local.zones[segment.name]), keys(local.zones[segment.name]), [traffic.zone])[0]
        stateless   = matchkeys(local.ports[*].stateless, local.ports[*].name, [traffic.port])[0]
        min_port    = matchkeys(local.ports[*].min, local.ports[*].name, [traffic.port])[0]
        max_port    = matchkeys(local.ports[*].max, local.ports[*].name, [traffic.port])[0]
      }}
    }}
    security_zones = local.zones
    subnets = {for subnet in local.subnets : subnet.name => {
      topology      = subnet.topology
      display_name  = "${local.service_name}_${index(local.vcn_list, segment.name) + 1}_${subnet.name}"
      cidr_block    = local.subnet_cidr[segment.name][subnet.name]
      dns_label     = "${local.service_label}${index(local.vcn_list, segment.name) + 1}${substr(subnet.name, 0, 3)}"
      route_table   = "${local.service_name}_${index(local.vcn_list, segment.name) + 1}_${subnet.route_table}_route"
      security_list = "${local.service_name}_${index(local.vcn_list, segment.name) + 1}_${subnet.name}_net_firewall"
    } if contains(var.resolve.topologies, subnet.topology)}
  }if segment.stage <= local.lifecycle[var.input.stage]}
}
# Copyright (c) 2020 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

locals {
    # Input Parameter
    channels  = jsondecode(templatefile("${path.module}/resident/channels.json", {owner = var.input.owner}))
    roles     = jsondecode(templatefile("${path.module}/resident/roles.json", {service = local.service_name}))
    controls  = jsondecode(file("${path.module}/resident/controls.json"))
    tags      = jsondecode(file("${path.module}/resident/tags.json"))
    subnets   = jsondecode(file("${path.module}/network/subnets.json"))
    routers   = jsondecode(file("${path.module}/network/routers.json"))
    routes    = jsondecode(file("${path.module}/network/routes.json"))
    destinations = jsondecode(file("${path.module}/network/destinations.json"))
    firewalls = jsondecode(file("${path.module}/network/firewalls.json"))
    ports     = jsondecode(file("${path.module}/network/ports.json"))
    # Computed Parameter
    service_name  = lower("${var.input.organization}_${var.input.solution}_${var.input.stage}")
    service_label = format(
        "%s%s%s", 
        lower(substr(var.input.organization, 0, 3)), 
        lower(substr(var.input.solution, 0, 2)),
        lower(substr(var.input.stage, 0, 3)),
    )
    classification = {
        free_tier   = 0
        commercial  = 1
        enterprise  = 2
        high_secure = 3
    }
    lifecycle = {
        DEV  = 0
        TEST = 1 
        PROD = 2
    }
    tag_namespaces = {for namespace in local.controls : namespace.name => namespace.stage} 
    # Merge tags with with the respective namespace information
    tag_map = zipmap(
        flatten([for tag in local.controls[*].tags : tag]),
        flatten([for control in local.controls : [for tag in control.tags : control.name]])
    ) 
    freeform_tags = {
        "framework" = "ocloud"
        "owner"     = var.input.owner
        "lifecycle" = var.input.stage
        "class"     = var.input.class
    }
    group_map = zipmap(
        flatten("${var.input.domains[*].roles}"),
        flatten([for domain in var.input.domains : [for role in domain.roles : "${local.service_name}_${domain.name}_compartment"]])
    )
    vcn_list   = var.input.segments[*].name
    router_map = {for router in local.routers : router.name => {
        name     = router.name
        cpe      = router.cpe
        anywhere = router.anywhere
    }}
    subnet_newbits = {for segment in var.input.segments : segment.name => zipmap(
        [for subnet in local.subnets : subnet.name if contains(segment.topology, subnet.topology)],
        [for subnet in local.subnets : subnet.newbits if contains(segment.topology, subnet.topology)]
    )}
    subnet_cidr = {for segment in var.input.segments : segment.name => zipmap(
        keys(local.subnet_newbits[segment.name]),
        flatten(cidrsubnets(segment.cidr, values(local.subnet_newbits[segment.name])...))
    )}
    defined_routes = {for segment in var.input.segments : segment.name => {
        "cpe"      = length(keys(local.router_map)) != 0 ? try(local.router_map[segment.name].cpe,local.router_map["default"].cpe) : null
        "internet" = length(keys(local.router_map)) != 0 ? try(local.router_map[segment.name].anywhere,local.router_map["default"].anywhere) : null
        "vcn"      = segment.cidr
        "osn"      = local.osn_cidrs.all
        "buckets"  = local.osn_cidrs.storage
    }}
    zones = {for segment in var.input.segments : segment.name => merge(
        local.defined_routes[segment.name],
        local.destinations[segment.name],
        local.subnet_cidr[segment.name]
    )}
}
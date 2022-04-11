// Copyright (c) 2020 Oracle and/or its affiliates.
// Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

output "service" {
  value = {
    budgets = merge(
      zipmap(
        flatten([for period in local.periods: [for alert in local.alerts: "${local.service_name}_${lower(period.type)}" if alert.name == "compartment" && period.name == "default" && var.solution.budget > 0]]),
        flatten([for period in local.periods: [for alert in local.alerts: {
          amount         = var.solution.budget
          budget_processing_period_start_offset = period.offset
          display_name   = "${local.service_name}_${lower(period.type)}"
          reset_period   = period.type
          stage          = 0
          target_type    = "COMPARTMENT"
          threshold      = alert.threshold
          threshold_type = alert.measure
        } if alert.name == "compartment" && period.name == "default" && var.solution.budget > 0]])
      ),
      zipmap(
        flatten([for domain in var.resident.domains: [for period in local.periods: [for alert in local.alerts: "${domain.name}_${lower(period.type)}" if alert.name == "compartment" && period.name == "default" && domain.budget > 0]]]),
        flatten([for domain in var.resident.domains: [for period in local.periods: [for alert in local.alerts: {
          amount = domain.budget
          budget_processing_period_start_offset = period.offset
          display_name   = "${domain.name}_${lower(period.type)}"
          reset_period   = period.type
          stage          = domain.stage
          target_type    = "COMPARTMENT"
          threshold      = alert.threshold
          threshold_type = alert.measure
        }if alert.name == "compartment" && period.name == "default" && domain.budget > 0]]])
      ),
      zipmap(
        flatten([for budget in local.budgets: [for period in local.periods: [for alert in local.alerts: "${budget.name}_${lower(period.type)}" if budget.alert == alert.name && budget.period == period.name]]]),
        flatten([for budget in local.budgets: [for period in local.periods: [for alert in local.alerts: {
          amount         = budget.amount
          budget_processing_period_start_offset = period.offset
          display_name   = "${budget.name}_${lower(period.type)}"
          reset_period   = period.type
          stage          = budget.stage
          target_type    = "TAG"
          threshold      = alert.threshold
          threshold_type = alert.measure
        }if budget.alert == alert.name && budget.period == period.name]]])
      )
    )
    compartments = {for domain in var.resident.domains : "${local.service_name}_${domain.name}_compartment" => domain.stage}
    groups       = {for operator in flatten(var.resident.domains[*].operators) : operator => "${local.service_name}_${operator}"}
    label        = local.service_label
    name         = local.service_name
    notifications = {for channel in local.channels : "${local.service_name}_${channel.name}" => {
      topic     = "${local.service_name}_${channel.name}"
      protocol  = channel.type
      endpoint  = channel.address
    } if contains(distinct(flatten("${var.resident.domains[*].channels}")), channel.name)}
    owner        = var.solution.owner
    policies     = {for operator in local.operators : operator.name => {
      name        = "${local.service_name}_${operator.name}"
      compartment = local.group_map[operator.name]
      rules       = operator.rules
    }if contains(keys(local.group_map), operator.name) }
    region       = {
      key  = local.region_key
      name = local.region_name
    }
    repository   = var.solution.repository
    stage        = local.lifecycle[var.solution.stage]
    tag_namespaces = {
      for namespace in local.controls : "${local.service_name}_${namespace.name}" => namespace.stage
    }
    tags = {for tag in local.tags : tag.name => {
      name          = tag.name
      namespace     = local.tag_map[tag.name]
      stage         = local.tag_namespaces["${local.tag_map[tag.name]}"]
      values        = tag.values
      default       = length(flatten([tag.values])) > 1 ? element(tag.values,0) : tostring(tag.values)
      cost_tracking = tag.cost_tracking
    }}
  }
}
# API Fields Reference

Generated: 2025-08-24T12:16:52.414585

API URL: `https://vgw1-01.dal-interurban.mdu.attwifi.com`

## Overview

This document lists all available fields for each API endpoint when called with `page_size=0`.

## Summary

| Endpoint | Path | Total Items | Total Fields |
|----------|------|-------------|--------------|
| rooms | `/api/pms_rooms.json` | 141 | 30 |
| access_points | `/api/access_points.json` | 220 | 126 |
| switches | `/api/switch_devices.json` | 1 | 161 |
| media_converters | `/api/media_converters.json` | 151 | 50 |
| wlan_controllers | `/api/wlan_devices.json` | 3 | 184 |

## Rooms

**Endpoint:** `/api/pms_rooms.json`

**Total Items:** 141

**Total Fields:** 30

### Top-Level Fields

| Field | Type | Sample Value |
|-------|------|--------------|
| `access_points` | list | list |
| `common_space` | bool | False |
| `created_at` | str | "2025-03-18T16:28:02.990-05:00" |
| `created_by` | str | "./import_pms_rooms" |
| `id` | int | 26 |
| `infrastructure_devices` | list | list |
| `iot_hubs` | list | list |
| `media_converters` | list | list |
| `pairwise_master_keys` | list | list |
| `pms_guests` | list | list |
| `pms_property` | dict | dict |
| `room` | str | "203" |
| `switch_ports` | list | list |
| `updated_at` | str | "2025-03-18T16:28:02.990-05:00" |
| `updated_by` | str | "./import_pms_rooms" |

### Nested Fields

| Field Path | Type |
|------------|------|
| `access_points.count` | unknown |
| `access_points[0].id` | int |
| `access_points[0].name` | str |
| `infrastructure_devices.count` | unknown |
| `iot_hubs.count` | unknown |
| `media_converters.count` | unknown |
| `media_converters[0].id` | int |
| `media_converters[0].name` | str |
| `pairwise_master_keys.count` | unknown |
| `pms_guests.count` | unknown |
| `pms_property.id` | int |
| `pms_property.name` | str |
| `switch_ports.count` | unknown |
| `switch_ports[0].id` | int |
| `switch_ports[0].name` | str |

### Recommended Field Sets

**For Summary/List View:**
```
only=id,name,room,building,floor,access_points,media_converters
```

**For Detail View (all fields):**
```
# Use without 'only' parameter to get all fields
```

## Access Points

**Endpoint:** `/api/access_points.json`

**Total Items:** 220

**Total Fields:** 126

### Top-Level Fields

| Field | Type | Sample Value |
|-------|------|--------------|
| `access_point_profile` | dict | dict |
| `access_point_radios` | list | list |
| `access_point_zone` | dict | dict |
| `ap_login_password` | str | "openwifi" |
| `ap_onboarding_status` | dict | dict |
| `approved` | bool | True |
| `certificate` | str | "-----BEGIN CERTIFICATE-----
MIIEwzCCA6ugAwIBAgIBAT" |
| `channel_24` | int | 6 |
| `channel_24_override` | int | 6 |
| `channel_24_plan` | int | 6 |
| `channel_5` | int | 42 |
| `channel_5_override` | int | 42 |
| `channel_5_plan` | int | 42 |
| `channel_6` | NoneType | null |
| `channel_6_override` | int | 0 |
| `channel_6_plan` | NoneType | null |
| `client_count` | NoneType | null |
| `color` | str | "#ff0000" |
| `command_executions` | list | list |
| `conference_access_point_profiles` | list | list |
| `conference_networks` | list | list |
| `connected_clients` | list | list |
| `connection_state` | str | "Unsubscribed" |
| `country` | NoneType | null |
| `created_at` | str | "2025-03-24T17:24:13.799-05:00" |
| `created_by` | str | "puma: cluster worker 0: 74925" |
| `csr` | str | "-----BEGIN CERTIFICATE REQUEST-----
MIIEnDCCAoQCAQ" |
| `description` | NoneType | null |
| `firmware_compatibility` | str | "cig_wf660a" |
| `icon` | NoneType | null |
| `id` | int | 127 |
| `images` | list | list |
| `infrastructure_area_location` | dict | dict |
| `infrastructure_areas` | list | list |
| `infrastructure_device` | dict | dict |
| `infrastructure_link` | dict | dict |
| `ip` | str | "10.100.3.53" |
| `last_seen_at` | str | "2025-08-24T11:16:23.257-05:00" |
| `last_subscribed_at` | str | "2025-08-24T11:14:55.042-05:00" |
| `last_unsubscribed_at` | NoneType | null |
| `latitude` | NoneType | null |
| `led_state` | NoneType | null |
| `location` | NoneType | null |
| `longitude` | NoneType | null |
| `mac` | str | "d4:ba:ba:a3:1d:d0" |
| `mesh` | NoneType | null |
| `model` | str | "Cigtech WF-660a" |
| `name` | str | "AP2-3-1dd0-WF660A-GARAGE_3A" |
| `neighbor_bssid_observations` | list | list |
| `neighbor_bssids` | list | list |
| `note` | NoneType | null |
| `online` | bool | False |
| `phase` | NoneType | null |
| `pifi_error` | NoneType | null |
| `ping_results` | list | list |
| `ping_targets` | list | list |
| `pms_room` | dict | dict |
| `radio_macs` | list | list |
| `radio_metric_graphs` | list | list |
| `radio_metrics` | list | list |
| `serial_number` | str | "d4babaa31dd0" |
| `speed_tests` | list | list |
| `switch_ports` | list | list |
| `tx_power_24` | NoneType | null |
| `tx_power_24_plan` | str | "" |
| `tx_power_5` | NoneType | null |
| `tx_power_5_plan` | str | "" |
| `tx_power_6` | NoneType | null |
| `tx_power_6_plan` | str | "" |
| `updated_at` | str | "2025-08-24T11:16:23.265-05:00" |
| `updated_by` | str | "anycable_rpc" |
| `uptime` | int | 420313 |
| `uuid` | str | "1755312212" |
| `version` | str | "TIP-rgnets-4.0.0-0.020-ba742de8" |
| `wireless_clients` | list | list |
| `wtp_mac` | NoneType | null |
| `x` | str | "35.088810001058" |
| `y` | str | "16.274960435862" |
| `zone` | str | "1" |

### Nested Fields

| Field Path | Type |
|------------|------|
| `access_point_profile.id` | int |
| `access_point_profile.name` | str |
| `access_point_radios.count` | unknown |
| `access_point_radios[0].id` | int |
| `access_point_radios[0].name` | str |
| `access_point_zone.id` | int |
| `access_point_zone.name` | str |
| `ap_onboarding_status.error` | NoneType |
| `ap_onboarding_status.last_seen_at` | str |
| `ap_onboarding_status.last_update` | str |
| `ap_onboarding_status.last_update_age_secs` | int |
| `ap_onboarding_status.max_stages` | int |
| `ap_onboarding_status.next_action` | str |
| `ap_onboarding_status.onboarding_complete` | bool |
| `ap_onboarding_status.online` | bool |
| `ap_onboarding_status.owgw_adoption_status` | NoneType |
| `ap_onboarding_status.stage` | int |
| `ap_onboarding_status.stage_display` | str |
| `ap_onboarding_status.status` | str |
| `command_executions.count` | unknown |

*... and 27 more nested fields*

### Recommended Field Sets

**For Summary/List View:**
```
only=id,name,online,mac_address,ip_address,model
```

**For Detail View (additional fields):**
```
only=id,name,online,mac_address,ip_address,model,serial_number,firmware_version,last_seen,created_at,updated_at
```

## Switches

**Endpoint:** `/api/switch_devices.json`

**Total Items:** 1

**Total Fields:** 161

### Top-Level Fields

| Field | Type | Sample Value |
|-------|------|--------------|
| `aaa_enable_methods` | str | "local" |
| `aaa_login_methods` | str | "local" |
| `access_point_profiles` | list | list |
| `access_point_radios` | list | list |
| `access_point_zones` | list | list |
| `access_points` | list | list |
| `api_host` | NoneType | null |
| `api_port` | NoneType | null |
| `api_version` | NoneType | null |
| `apikey` | NoneType | null |
| `auth_default_vlan` | NoneType | null |
| `auto_approve` | bool | False |
| `auto_update_device_names` | bool | True |
| `auto_update_fw` | bool | False |
| `client_id` | NoneType | null |
| `client_secret` | NoneType | null |
| `color` | str | "#00ff00" |
| `community_string` | str | "public" |
| `config_sync_paused` | bool | False |
| `configure_hotspot_wlan` | bool | False |
| `connected_clients` | list | list |
| `cookie` | NoneType | null |
| `create_location_events` | bool | True |
| `created_at` | str | "2025-03-18T13:54:36.778-05:00" |
| `created_by` | str | "jmb" |
| `customer_id` | NoneType | null |
| `data_port` | NoneType | null |
| `device` | str | "nokiapon" |
| `device_firmwares` | list | list |
| `disable_background_ssh` | bool | False |
| `dns_server_address` | NoneType | null |
| `document_manual` | NoneType | null |
| `document_other` | NoneType | null |
| `domain_filter` | NoneType | null |
| `enable_ap_port_management` | bool | False |
| `enable_telemetry` | NoneType | null |
| `encrypted_enable_password` | NoneType | null |
| `encrypted_enable_password_iv` | NoneType | null |
| `encrypted_olt_password` | str | "HyZ+7RmMnsHjGSZPww2FT+oETKHn
" |
| `encrypted_olt_password_iv` | str | "yamku68vwymvqAA2
" |
| `encrypted_password` | str | "6HSsliroHfUX3AQPrFEz6XfJSIu+t7iR
" |
| `encrypted_password_iv` | str | "KH7cgtRmpWolWege
" |
| `gateway_ip` | NoneType | null |
| `grpc_port` | NoneType | null |
| `grpc_wan_targets` | list | list |
| `host` | str | "10.99.0.6" |
| `hostname` | str | "MF2-01" |
| `icon` | NoneType | null |
| `id` | int | 70 |
| `image_front` | NoneType | null |
| `image_other` | NoneType | null |
| `image_rear` | NoneType | null |
| `images` | list | list |
| `inf_dev_users` | list | list |
| `infrastructure_areas` | list | list |
| `inline_power_allocation_dynamic_all` | bool | False |
| `instrument_from` | str | "integration" |
| `ip_group` | dict | dict |
| `ip_multicast_active` | NoneType | null |
| `ip_multicast_disable_flooding` | bool | True |
| `ip_multicast_version_3` | bool | True |
| `last_config_sync_at` | str | "2025-08-23T20:40:00.454-05:00" |
| `last_config_sync_attempt_at` | str | "2025-08-23T20:39:51.504-05:00" |
| `license` | str | "AC4wLAIUId25RLeQEdwKw+PffuYLwJCta3ACFBUw+5IUmZwD5h" |
| `login_recovery_time` | NoneType | null |
| `login_role` | NoneType | null |
| `loopback_ip` | NoneType | null |
| `mac` | str | "28:6f:b9:e7:c1:d9" |
| `managed_account` | NoneType | null |
| `management_port` | NoneType | null |
| `management_vlan` | int | 1 |
| `manager_active_list` | str | "" |
| `manager_registrar` | bool | False |
| `max_login_failures` | NoneType | null |
| `media_converters` | list | list |
| `model` | str | "MF-2 (LS-MF-LMNT-B)" |
| `monitoring_enabled` | bool | True |
| `monitoring_interval` | int | 10 |
| `name` | str | "MF2-01" |
| `nb_portal_password` | NoneType | null |
| `nb_portal_username` | NoneType | null |
| `network` | NoneType | null |
| `nickname` | NoneType | null |
| `note` | NoneType | null |
| `olt_ip` | str | "10.40.93.11" |
| `olt_name` | str | "MF2-01" |
| `olt_network_card_layout` | str | "all-25g" |
| `olt_pon_card_layout` | str | "LT1" |
| `olt_username` | str | "admin" |
| `online` | bool | True |
| `optical_monitor` | bool | False |
| `periodic_config_check` | bool | False |
| `periodic_config_check_interval` | NoneType | null |
| `periodic_config_check_last_run` | NoneType | null |
| `periodic_resync_if_diff` | bool | False |
| `phase` | NoneType | null |
| `port` | int | 22 |
| `privilege_level` | NoneType | null |
| `protocol` | str | "ssh_coa" |
| `radio_metrics` | list | list |
| `radius_servers` | list | list |
| `scratch` | str | "28:6f:b9:e7:c1:d9" |
| `serial_number` | str | "YP2444SH085" |
| `site` | NoneType | null |
| `snmp_port` | int | 161 |
| `spanning_tree` | bool | False |
| `static_routes` | list | list |
| `stp_priority` | NoneType | null |
| `subnet` | NoneType | null |
| `switch_custom_configs` | list | list |
| `switch_ports` | list | list |
| `sync_timezone` | bool | False |
| `sync_type` | str | "all" |
| `sync_users` | bool | False |
| `system_graphs` | list | list |
| `system_name` | NoneType | null |
| `telemetry_last_seen_at` | NoneType | null |
| `telemetry_psk` | NoneType | null |
| `telemetry_username` | NoneType | null |
| `timeout` | int | 30 |
| `trusted_dhcp_vlans` | list | list |
| `type` | str | "SwitchDevice" |
| `updated_at` | str | "2025-08-24T08:02:34.122-05:00" |
| `updated_by` | str | "nokia_pon" |
| `upgrade_status` | NoneType | null |
| `username` | str | "adminuser" |
| `version` | str | "24.12" |
| `web_management_disable` | bool | False |
| `wired_clients` | list | list |
| `wireless_clients` | list | list |
| `wlans` | list | list |
| `x` | NoneType | null |
| `y` | NoneType | null |
| `zone` | NoneType | null |
| `zone_filter` | NoneType | null |

### Nested Fields

| Field Path | Type |
|------------|------|
| `access_point_profiles.count` | unknown |
| `access_point_radios.count` | unknown |
| `access_point_zones.count` | unknown |
| `access_points.count` | unknown |
| `connected_clients.count` | unknown |
| `device_firmwares.count` | unknown |
| `grpc_wan_targets.count` | unknown |
| `inf_dev_users.count` | unknown |
| `infrastructure_areas.count` | unknown |
| `ip_group.id` | int |
| `ip_group.name` | str |
| `media_converters.count` | unknown |
| `media_converters[0].id` | int |
| `media_converters[0].name` | str |
| `radio_metrics.count` | unknown |
| `radius_servers.count` | unknown |
| `static_routes.count` | unknown |
| `switch_custom_configs.count` | unknown |
| `switch_ports.count` | unknown |
| `switch_ports[0].id` | int |

*... and 6 more nested fields*

### Recommended Field Sets

**For Summary/List View:**
```
only=id,name,online,mac_address,ip_address,model
```

**For Detail View (additional fields):**
```
only=id,name,online,mac_address,ip_address,model,serial_number,firmware_version,last_seen,created_at,updated_at
```

## Media Converters

**Endpoint:** `/api/media_converters.json`

**Total Items:** 151

**Total Fields:** 50

### Top-Level Fields

| Field | Type | Sample Value |
|-------|------|--------------|
| `approved` | bool | False |
| `connection_state` | str | "Unapproved" |
| `created_at` | str | "2025-06-04T15:12:28.931-05:00" |
| `created_by` | str | "monitor_infrastructure" |
| `detail_json` | NoneType | null |
| `hidden_from_portal` | bool | True |
| `id` | int | 392 |
| `images` | list | list |
| `infrastructure_device` | dict | dict |
| `is_registered` | bool | False |
| `mac` | NoneType | null |
| `model` | str | "880" |
| `name` | str | "ONT1-1-F14B-" |
| `note` | NoneType | null |
| `online` | bool | True |
| `ont_id` | str | "0" |
| `ont_onboarding_status` | dict | dict |
| `ont_profile` | str | "rgn_U-880CP-P" |
| `pms_room` | dict | dict |
| `port_type` | str | "xgs" |
| `scratch` | NoneType | null |
| `serial_number` | str | "ALCLFD57F14B" |
| `switch_port` | dict | dict |
| `switch_ports` | list | list |
| `updated_at` | str | "2025-06-09T16:18:34.622-05:00" |
| `updated_by` | str | "monitor_infrastructure" |
| `uptime` | NoneType | null |
| `version` | NoneType | null |

### Nested Fields

| Field Path | Type |
|------------|------|
| `infrastructure_device.id` | int |
| `infrastructure_device.name` | str |
| `ont_onboarding_status.error` | NoneType |
| `ont_onboarding_status.is_registered` | bool |
| `ont_onboarding_status.last_update` | str |
| `ont_onboarding_status.last_update_age_secs` | int |
| `ont_onboarding_status.max_stages` | int |
| `ont_onboarding_status.model` | str |
| `ont_onboarding_status.olt_port` | str |
| `ont_onboarding_status.onboarding_complete` | bool |
| `ont_onboarding_status.online` | bool |
| `ont_onboarding_status.ont_ports` | list |
| `ont_onboarding_status.stage` | int |
| `ont_onboarding_status.stage_display` | str |
| `ont_onboarding_status.status` | str |
| `pms_room.id` | int |
| `pms_room.name` | str |
| `switch_port.id` | int |
| `switch_port.name` | str |
| `switch_ports.count` | unknown |

*... and 2 more nested fields*

### Recommended Field Sets

**For Summary/List View:**
```
only=id,name,online,mac_address,ip_address,model
```

**For Detail View (additional fields):**
```
only=id,name,online,mac_address,ip_address,model,serial_number,firmware_version,last_seen,created_at,updated_at
```

## Wlan Controllers

**Endpoint:** `/api/wlan_devices.json`

**Total Items:** 3

**Total Fields:** 184

### Top-Level Fields

| Field | Type | Sample Value |
|-------|------|--------------|
| `aaa_enable_methods` | str | "local" |
| `aaa_login_methods` | str | "local" |
| `access_point_profiles` | list | list |
| `access_point_radios` | list | list |
| `access_point_zones` | list | list |
| `access_points` | list | list |
| `api_host` | NoneType | null |
| `api_port` | NoneType | null |
| `api_version` | NoneType | null |
| `apikey` | NoneType | null |
| `auth_default_vlan` | NoneType | null |
| `auto_approve` | bool | False |
| `auto_update_device_names` | bool | False |
| `auto_update_fw` | bool | False |
| `certificate_authority` | dict | dict |
| `client_id` | NoneType | null |
| `client_secret` | NoneType | null |
| `color` | str | "#00ff00" |
| `community_string` | str | "public" |
| `config_sync_paused` | bool | False |
| `configure_hotspot_wlan` | bool | False |
| `connected_clients` | list | list |
| `cookie` | NoneType | null |
| `create_location_events` | bool | True |
| `created_at` | str | "2025-06-04T19:03:32.622-05:00" |
| `created_by` | str | "mdk" |
| `customer_id` | NoneType | null |
| `data_port` | NoneType | null |
| `device` | str | "wlanpi" |
| `device_firmwares` | list | list |
| `disable_background_ssh` | bool | False |
| `dns_server_address` | NoneType | null |
| `document_manual` | NoneType | null |
| `document_other` | NoneType | null |
| `domain_filter` | NoneType | null |
| `enable_ap_port_management` | bool | False |
| `enable_telemetry` | bool | True |
| `encrypted_enable_password` | NoneType | null |
| `encrypted_enable_password_iv` | NoneType | null |
| `encrypted_olt_password` | NoneType | null |
| `encrypted_olt_password_iv` | NoneType | null |
| `encrypted_password` | str | "gxoc6q60CBcjrNL8z03cOCw4ziXl/IGn1+oso+ClCkkljJVEra" |
| `encrypted_password_iv` | str | "AwNZpgHANLmWMXIu
" |
| `gateway_ip` | NoneType | null |
| `grpc_port` | NoneType | null |
| `grpc_wan_targets` | list | list |
| `host` | str | "127.0.0.1" |
| `hostname` | NoneType | null |
| `icon` | NoneType | null |
| `id` | int | 106 |
| `image_front` | NoneType | null |
| `image_other` | NoneType | null |
| `image_rear` | NoneType | null |
| `images` | list | list |
| `inf_dev_users` | list | list |
| `infrastructure_areas` | list | list |
| `inline_power_allocation_dynamic_all` | bool | False |
| `instrument_from` | str | "telemetry" |
| `ip_group` | dict | dict |
| `ip_multicast_active` | NoneType | null |
| `ip_multicast_disable_flooding` | bool | True |
| `ip_multicast_version_3` | bool | True |
| `last_config_sync_at` | str | "2025-07-08T16:43:55.397-05:00" |
| `last_config_sync_attempt_at` | str | "2025-07-08T16:43:51.377-05:00" |
| `license` | NoneType | null |
| `login_recovery_time` | NoneType | null |
| `login_role` | NoneType | null |
| `loopback_ip` | NoneType | null |
| `mac` | NoneType | null |
| `managed_account` | NoneType | null |
| `management_port` | NoneType | null |
| `management_vlan` | int | 1 |
| `manager_active_list` | str | "" |
| `manager_registrar` | bool | False |
| `max_login_failures` | NoneType | null |
| `media_converters` | list | list |
| `model` | NoneType | null |
| `monitoring_enabled` | bool | True |
| `monitoring_interval` | int | 10 |
| `mqttd_option` | dict | dict |
| `name` | str | "WLAN Pi Controller" |
| `nb_portal_password` | NoneType | null |
| `nb_portal_username` | NoneType | null |
| `network` | NoneType | null |
| `nickname` | NoneType | null |
| `note` | NoneType | null |
| `olt_ip` | NoneType | null |
| `olt_name` | NoneType | null |
| `olt_network_card_layout` | NoneType | null |
| `olt_pon_card_layout` | NoneType | null |
| `olt_username` | NoneType | null |
| `online` | bool | True |
| `optical_monitor` | bool | False |
| `periodic_config_check` | bool | False |
| `periodic_config_check_interval` | NoneType | null |
| `periodic_config_check_last_run` | NoneType | null |
| `periodic_resync_if_diff` | bool | False |
| `phase` | NoneType | null |
| `port` | int | 22 |
| `privilege_level` | NoneType | null |
| `protocol` | str | "ssh_coa" |
| `radio_metrics` | list | list |
| `radius_servers` | list | list |
| `scratch` | NoneType | null |
| `serial_number` | NoneType | null |
| `site` | NoneType | null |
| `snmp_port` | int | 161 |
| `spanning_tree` | bool | False |
| `static_routes` | list | list |
| `stp_priority` | NoneType | null |
| `subnet` | NoneType | null |
| `switch_custom_configs` | list | list |
| `switch_ports` | list | list |
| `sync_timezone` | bool | False |
| `sync_type` | str | "all" |
| `sync_users` | bool | False |
| `system_graphs` | list | list |
| `system_name` | NoneType | null |
| `telemetry_last_seen_at` | NoneType | null |
| `telemetry_psk` | NoneType | null |
| `telemetry_username` | NoneType | null |
| `timeout` | int | 30 |
| `trusted_dhcp_vlans` | list | list |
| `type` | str | "WlanDevice" |
| `updated_at` | str | "2025-06-12T18:58:06.065-05:00" |
| `updated_by` | str | "mdk" |
| `upgrade_status` | NoneType | null |
| `username` | str | "admin" |
| `version` | NoneType | null |
| `virtual_machine` | dict | dict |
| `web_management_disable` | bool | False |
| `wired_clients` | list | list |
| `wireless_clients` | list | list |
| `wlans` | list | list |
| `x` | NoneType | null |
| `y` | NoneType | null |
| `zone` | NoneType | null |
| `zone_filter` | NoneType | null |

### Nested Fields

| Field Path | Type |
|------------|------|
| `access_point_profiles.count` | unknown |
| `access_point_profiles[0].id` | int |
| `access_point_profiles[0].name` | str |
| `access_point_radios.count` | unknown |
| `access_point_radios[0].id` | int |
| `access_point_radios[0].name` | str |
| `access_point_zones.count` | unknown |
| `access_point_zones[0].id` | int |
| `access_point_zones[0].name` | str |
| `access_points.count` | unknown |
| `access_points[0].id` | int |
| `access_points[0].name` | str |
| `certificate_authority.id` | int |
| `certificate_authority.name` | str |
| `connected_clients.count` | unknown |
| `connected_clients[0].id` | int |
| `device_firmwares.count` | unknown |
| `device_firmwares[0].id` | int |
| `device_firmwares[0].name` | str |
| `grpc_wan_targets.count` | unknown |

*... and 26 more nested fields*

### Recommended Field Sets

**For Summary/List View:**
```
only=id,name,online,mac_address,ip_address,model
```

**For Detail View (additional fields):**
```
only=id,name,online,mac_address,ip_address,model,serial_number,firmware_version,last_seen,created_at,updated_at
```

## Performance Optimization Strategy

### Hierarchical Data Loading

1. **Initial Load (< 500ms):** Fetch minimal fields for counts and summary
2. **List View Load (< 2s):** Fetch fields needed for list display
3. **Detail Load (on-demand):** Fetch complete data when user views details

### Example Usage

```bash
# Step 1: Quick summary
GET /api/access_points.json?page_size=0&only=id,name,online

# Step 2: List view data
GET /api/access_points.json?page_size=0&only=id,name,online,mac_address,ip_address,model

# Step 3: Full details (on demand)
GET /api/access_points/{id}.json
```
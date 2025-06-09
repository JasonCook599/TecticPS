<#PSScriptInfo

.VERSION 1.0.10

.GUID 93f5aa38-3ef7-4d57-8225-1ba9e7167243

.AUTHOR Jason Cook

.COMPANYNAME Tectic

.COPYRIGHT Copyright (c) Tectic 2025

.TAGS

.LICENSEURI

.PROJECTURI

.ICONURI

.EXTERNALMODULEDEPENDENCIES 

.REQUIREDSCRIPTS

.EXTERNALSCRIPTDEPENDENCIES

.RELEASENOTES

.PRIVATEDATA

#> 





<#
.DESCRIPTION
Used to generate a config file for FortiClient VPN.

.PARAMETER Path
Where should the config file be saved?

.PARAMETER Locations
A hastable of the location names and gateways.

.PARAMETER AllGateways
The name of the VPN conections to create containing all gateways.

.PARAMETER Start
The start of the XML file.

.PARAMETER End
The end of the XML file, after all the connections are created.
#>

[CmdletBinding(SupportsShouldProcess = $true)]
param(
  [Parameter(ValueFromPipeline = $true)][string]$Path,
  [Parameter(ValueFromPipeline = $true)][hashtable]$Locations,
  [Parameter(ValueFromPipeline = $true)][string]$AllGateways,
  $Start = '
<?xml version="1.0" encoding="UTF-8" ?>
<forticlient_configuration>
    <forticlient_version>6.0.10.297</forticlient_version>
    <version>6.0.10</version>
    <exported_by_version>6.0.10.0297</exported_by_version>
    <date>2022/07/05</date>
    <partial_configuration>0</partial_configuration>
    <os_version>windows</os_version>
    <os_architecture>x64</os_architecture>
    <system>
        <ui>
            <disable_backup>0</disable_backup>
            <ads>1</ads>
            <default_tab>VPN</default_tab>
            <flashing_system_tray_icon>1</flashing_system_tray_icon>
            <hide_system_tray_icon>0</hide_system_tray_icon>
            <suppress_admin_prompt>0</suppress_admin_prompt>
            <password />
            <hide_user_info>0</hide_user_info>
            <culture_code>os-default</culture_code>
            <gpu_rendering>0</gpu_rendering>
            <replacement_messages>
                <quarantine>
                    <title>
                        <title>
                            <![CDATA[EncX B3BE58EB0FD91B6B866DF7E9459BEB7F0697746CE89427F20469594DB893779458DFF6A49EFC8898C44D4C37309DCB818B9D6EB3174F8CF2676EF458E1AADA1C0E9852D7E752091EAA4F1FE80044]]>
                        </title>
                    </title>
                    <statement>
                        <remediation>
                            <![CDATA[EncX D902BBB4D91522281CB2C525118B12D7790277C80142DE997D307E083A62FD471E58C7F0CCF1]]>
                        </remediation>
                    </statement>
                    <remediation>
                        <remediation>
                            <![CDATA[EncX 8484E04F33E964972BED5802A862373493F46245F243FC580640A599612B7705E42ABE874CBC76EECB4BB5BB96EAF652BD28F128F0D16B5E258BBB8A7099F96BE16D3B48EDC03159C3C61C87AECACC3D44D311D323DD5048D03F9640882166805562E45B5D89A6B0249CAA2ADC208E838AECF2]]>
                        </remediation>
                    </remediation>
                </quarantine>
            </replacement_messages>
        </ui>
        <log_settings>
            <onnet_local_logging>1</onnet_local_logging>
            <level>6</level>
            <log_events>ipsecvpn,sslvpn,scheduler,update,firewall</log_events>
            <remote_logging>
                <log_upload_enabled>0</log_upload_enabled>
                <log_upload_server />
                <log_upload_ssl_enabled>1</log_upload_ssl_enabled>
                <log_retention_days>90</log_retention_days>
                <log_upload_freq_minutes>60</log_upload_freq_minutes>
                <log_generation_timeout_secs>900</log_generation_timeout_secs>
                <netlog_categories>0</netlog_categories>
                <log_protocol>faz</log_protocol>
                <netlog_server />
            </remote_logging>
        </log_settings>
        <proxy>
            <update>0</update>
            <online_scep>0</online_scep>
            <type>http</type>
            <address />
            <port>80</port>
            <username>
                <![CDATA[Enc c3576adf25674d0e8657f64357e0eca3c8ff8f09ad4a07ce]]>
            </username>
            <password>
                <![CDATA[Enc 715ec34363eda0d92f180c6926fa6e7e19f18b19ae60b178]]>
            </password>
        </proxy>
        <update>
            <use_custom_server>0</use_custom_server>
            <restrict_services_to_regions />
            <server />
            <port>80</port>
            <timeout>60</timeout>
            <failoverport />
            <fail_over_to_fdn>1</fail_over_to_fdn>
            <use_proxy_when_fail_over_to_fdn>1</use_proxy_when_fail_over_to_fdn>
            <auto_patch>0</auto_patch>
            <submit_virus_info_to_fds>1</submit_virus_info_to_fds>
            <submit_vuln_info_to_fds>1</submit_vuln_info_to_fds>
            <update_action>download_and_install</update_action>
            <scheduled_update>
                <enabled>1</enabled>
                <type>interval</type>
                <daily_at>06:09</daily_at>
                <update_interval_in_hours>6</update_interval_in_hours>
            </scheduled_update>
        </update>
        <fortiproxy>
            <enabled>1</enabled>
            <enable_https_proxy>1</enable_https_proxy>
            <http_timeout>60</http_timeout>
            <client_comforting>
                <pop3_client>1</pop3_client>
                <pop3_server>1</pop3_server>
                <smtp>1</smtp>
            </client_comforting>
            <selftest>
                <enabled>1</enabled>
                <last_port>65535</last_port>
                <notify>1</notify>
            </selftest>
        </fortiproxy>
        <certificates>
            <crl>
                <ocsp>
                    <enabled>0</enabled>
                    <server />
                    <port />
                </ocsp>
            </crl>
            <hdd />
            <ca />
        </certificates>
    </system>
    <endpoint_control>
        <enabled>1</enabled>
        <socket_connect_timeouts>1:5</socket_connect_timeouts>
        <system_data>Enc 0dae8cf21fd55eea5d2961a1418235552038b0c924af92486ca781f294b60b765aa6926a792f8f91a177d2975d5b32aed2145e67f1f764d2331451a73b0378c16bcb11a1e63534dfd3201a9e</system_data>
        <disable_unregister>0</disable_unregister>
        <disable_fgt_switch>0</disable_fgt_switch>
        <show_bubble_notifications>1</show_bubble_notifications>
        <avatar_enabled>1</avatar_enabled>
        <ui>
            <display_antivirus>0</display_antivirus>
            <display_webfilter>0</display_webfilter>
            <display_firewall>0</display_firewall>
            <display_vpn>1</display_vpn>
            <display_vulnerability_scan>0</display_vulnerability_scan>
            <display_sandbox>0</display_sandbox>
            <display_compliance>0</display_compliance>
            <hide_compliance_warning>0</hide_compliance_warning>
            <registration_dialog>
                <show_profile_details>1</show_profile_details>
            </registration_dialog>
        </ui>
        <onnet_addresses>
            <address />
        </onnet_addresses>
        <onnet_mac_addresses />
        <alerts>
            <notify_server>1</notify_server>
            <alert_threshold>1</alert_threshold>
        </alerts>
        <fortigates>
            <fortigate>
                <serial_number />
                <name />
                <registration_password />
                <addresses />
            </fortigate>
        </fortigates>
        <local_subnets_only>0</local_subnets_only>
        <notification_server />
        <nac>
            <processes>
                <process id="" rule="present">
                    <signature name="" />
                </process>
            </processes>
            <files>
                <path id="" />
            </files>
            <registry>
                <path id="" />
            </registry>
        </nac>
    </endpoint_control>
    <vpn>
        <options>
            <autoconnect_tunnel />
            <autoconnect_only_when_offnet>0</autoconnect_only_when_offnet>
            <keep_running_max_tries>0</keep_running_max_tries>
            <disable_internet_check>0</disable_internet_check>
            <suppress_vpn_notification>0</suppress_vpn_notification>
            <minimize_window_on_connect>1</minimize_window_on_connect>
            <allow_personal_vpns>1</allow_personal_vpns>
            <disable_connect_disconnect>0</disable_connect_disconnect>
            <show_vpn_before_logon>1</show_vpn_before_logon>
            <use_windows_credentials>1</use_windows_credentials>
            <use_legacy_vpn_before_logon>0</use_legacy_vpn_before_logon>
            <show_negotiation_wnd>0</show_negotiation_wnd>
            <vendor_id />
        </options>
        <sslvpn>
            <options>
                <enabled>1</enabled>
                <prefer_sslvpn_dns>1</prefer_sslvpn_dns>
                <dnscache_service_control>0</dnscache_service_control>
                <use_legacy_ssl_adapter>0</use_legacy_ssl_adapter>
                <preferred_dtls_tunnel>1</preferred_dtls_tunnel>
                <block_ipv6>0</block_ipv6>
                <no_dhcp_server_route>0</no_dhcp_server_route>
                <no_dns_registration>0</no_dns_registration>
                <disallow_invalid_server_certificate>0</disallow_invalid_server_certificate>
            </options>
            <connections>',
  $End = '
            </connections>
        </sslvpn>
        <ipsecvpn>
            <options>
                <enabled>1</enabled>
                <beep_if_error>0</beep_if_error>
                <usewincert>1</usewincert>
                <use_win_current_user_cert>1</use_win_current_user_cert>
                <use_win_local_computer_cert>1</use_win_local_computer_cert>
                <block_ipv6>1</block_ipv6>
                <uselocalcert>0</uselocalcert>
                <usesmcardcert>1</usesmcardcert>
                <enable_udp_checksum>0</enable_udp_checksum>
                <disable_default_route>0</disable_default_route>
                <show_auth_cert_only>0</show_auth_cert_only>
                <check_for_cert_private_key>0</check_for_cert_private_key>
                <enhanced_key_usage_mandatory>0</enhanced_key_usage_mandatory>
            </options>
            <connections />
        </ipsecvpn>
    </vpn>
</forticlient_configuration>
'
)

function BuildConfig {
  Param(
    [ValidateLength(1, 31)][string]$Name,
    [ValidatePattern('(?m)^(?:\w|.)*:[1-9][0-9]{0,3}|[1-5][0-9]{4}|6[0-4][0-9]{3}|65[0-4][0-9]{2}|655[0-2][0-9]|6553[0-5]')][string]$Gateway
  )
  return "
    <connection>
        <name>$Name</name>
        <description />
        <server>$Gateway</server>
        <username />
        <single_user_mode>0</single_user_mode>
        <ui>
            <show_remember_password>0</show_remember_password>
            <show_alwaysup>0</show_alwaysup>
        </ui>
        <password />
        <warn_invalid_server_certificate>1</warn_invalid_server_certificate>
        <prompt_certificate>0</prompt_certificate>
        <prompt_username>1</prompt_username>
        <on_connect>
            <script>
                <os>windows</os>
                <script>
                    <![CDATA[]]>
                </script>
            </script>
        </on_connect>
        <on_disconnect>
            <script>
                <os>windows</os>
                <script>
                    <![CDATA[]]>
                </script>
            </script>
        </on_disconnect>
    </connection>"
}

$Mid = ""
if ($AllGateways) { $Mid += BuildConfig -Name $AllGateways -Gateway (($Locations.Values | Sort-Object ) -join ";") }
$Locations.Keys | ForEach-Object { $Mid += BuildConfig -Name $_ -Gateway $Locations[$_] }
$Config = ($Start + $Mid + $End)
If ($PSCmdlet.ShouldProcess("$Path", "Create-FortiClientConfig")) { Set-Content -Path $Path -Value $Config }
else { return $Config }

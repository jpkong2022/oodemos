namespace: ai
flow:
  name: configure_cisco_ucs_vlan
  inputs:
    - ucs_host: "ucs-manager.example.local"
    - username: "administrator"
    - password:
        default: "${get_sp('ucs_admin_pwd')}"
        sensitive: true
    - vlan_name: "VLAN-100-Prod"
    - vlan_id: "100"
    - switch_id: "A"
    - slot_id: "1"
    - port_id: "1"
  workflow:
    - configure_ucs_vlan_step:
        do:
          io.cloudslang.base.powershell.powershell_script:
            - host: "${ucs_host}"
            - port: '5985'
            - protocol: http
            - username: "${username}"
            - password:
                value: "${password}"
                sensitive: true
            - auth_type: basic
            - script: |
                Import-Module CiscoUcsPowerTool -ErrorAction Stop
                $secPw = ConvertTo-SecureString "${password}" -AsPlainText -Force
                $cred = New-Object System.Management.Automation.PSCredential ("${username}", $secPw)
                Connect-Ucs -Name "${ucs_host}" -Credential $cred -ErrorAction Stop
                $LanCloud = Get-UcsLanCloud -Level 1
                Add-UcsVlan -LanCloud $LanCloud -Name "${vlan_name}" -Id ${vlan_id} -Sharing "none" -ErrorAction Stop
                $EtherPort = Get-UcsEthLanPort -SwitchId "${switch_id}" -SlotId ${slot_id} -PortId ${port_id}
                if ($EtherPort) {
                    Add-UcsVlanMember -FabricEthLanPort $EtherPort -Name "${vlan_name}"
                } else {
                    Write-Error "Fabric Interconnect port not found."
                    exit 1
                }
                Disconnect-Ucs
            - trust_all_roots: 'true'
            - x_509_hostname_verifier: allow_all
        navigate:
          SUCCESS: SUCCESS
          FAILURE: on_failure
  results:
    - SUCCESS
    - FAILURE
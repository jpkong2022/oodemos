namespace: ai
flow:
  name: create_assign_ucs_vlan
  inputs:
    - ucs_host: '10.0.0.50'
    - ucs_username: 'admin'
    - ucs_password:
        value: 'ucs_password'
        sensitive: true
    - vlan_id: '100'
    - vlan_name: 'VLAN-100'
    - switch_id: 'A'
    - slot_id: '1'
    - port_id: '5'
  workflow:
    - execute_ucs_vlan_script:
        do:
          io.cloudslang.base.powershell.powershell_script:
            - host: 172.31.34.122
            - port: '5985'
            - protocol: http
            - username: administrator
            - password:
                value: "${get_sp('winserver1_admin_pwd')}"
                sensitive: true
            - auth_type: basic
            - script: |
                $ucsHost = "${ucs_host}"
                $ucsUser = "${ucs_username}"
                $ucsPass = "${ucs_password}"
                $vlanId = "${vlan_id}"
                $vlanName = "${vlan_name}"
                $switchId = "${switch_id}"
                $slotId = "${slot_id}"
                $portId = "${port_id}"
                
                $secString = ConvertTo-SecureString $ucsPass -AsPlainText -Force
                $credential = New-Object System.Management.Automation.PSCredential ($ucsUser, $secString)
                
                Import-Module Cisco.Ucs
                Connect-Ucs -Name $ucsHost -Credential $credential
                
                try {
                    Get-UcsLanCloud | Add-UcsVlan -Id $vlanId -Name $vlanName
                    Write-Host "Successfully created VLAN $vlanName"
                    
                    Get-UcsEthEp -SwitchId $switchId -SlotId $slotId -PortId $portId | Add-UcsFabricEthVlanEp -Name $vlanName
                    Write-Host "Successfully assigned VLAN $vlanName to Switch $switchId Slot $slotId Port $portId"
                }
                catch {
                    Write-Error "Failed to configure UCS: $_"
                    Disconnect-Ucs
                    exit 1
                }
                
                Disconnect-Ucs
            - trust_all_roots: 'true'
            - x_509_hostname_verifier: allow_all
        navigate:
          - SUCCESS: SUCCESS
          - FAILURE: on_failure
  results:
    - SUCCESS
    - FAILURE

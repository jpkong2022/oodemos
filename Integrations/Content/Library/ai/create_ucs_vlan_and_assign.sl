namespace: ai
flow:
  name: create_ucs_vlan_and_assign
  workflow:
    - execute_ucs_vlan_configuration:
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
                Import-Module Cisco.UcsManager
                
                $ucsHost = "192.168.1.100" # Replace with actual UCS Manager IP
                $ucsUser = "admin"
                $ucsPass = "UcsAdminPassword!" # Replace or parameterize
                $vlanId = "100"
                $vlanName = "VLAN100"
                
                $securePass = ConvertTo-SecureString $ucsPass -AsPlainText -Force
                $cred = New-Object System.Management.Automation.PSCredential($ucsUser, $securePass)
                
                # Connect to UCS Manager domain
                Connect-Ucs -Name $ucsHost -Credential $cred
                
                # Create a new VLAN in the LAN cloud
                Get-UcsLanCloud | Add-UcsVlan -Id $vlanId -Name $vlanName -DefaultNet "no"
                Write-Host "Successfully created $vlanName with ID $vlanId in LAN cloud."
                
                # Assign it to a physical server port / uplink port on Fabric Interconnect
                # Example: Fabric Interconnect A, Slot 1, Port 5
                Get-UcsEthUplinkPort -SlotId 1 -PortId 5 | Add-UcsEthUplinkPortVlan -Name $vlanName
                Write-Host "Successfully assigned $vlanName to Fabric Interconnect physical port 1/5."
                
                # Disconnect session
                Disconnect-Ucs
            - trust_all_roots: 'true'
            - x_509_hostname_verifier: allow_all
        navigate:
          - SUCCESS: SUCCESS
          - FAILURE: on_failure
  results:
    - SUCCESS
    - FAILURE

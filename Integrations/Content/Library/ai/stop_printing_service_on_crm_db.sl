namespace: ai
flow:
  name: stop_printing_service_on_crm_db
  workflow:
    - stop_print_service:
        do:
          io.cloudslang.base.powershell.powershell_script:
            - host: 172.31.43.41
            - port: '5985'
            - protocol: http
            - username: administrator
            - password:
                value: "${get_sp('dbserver_admin_pwd')}"
                sensitive: true
            - auth_type: basic
            - script: "Stop-Service -Name 'Spooler' -Force"
            - trust_all_roots: 'true'
            - x_509_hostname_verifier: allow_all
        navigate:
          - SUCCESS: SUCCESS
          - FAILURE: on_failure
  results:
    - SUCCESS
    - FAILURE

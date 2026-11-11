namespace: ai
flow:
  name: send_msteams_message
  inputs:
    - webhook_url:
        required: true
        sensitive: true
    - message:
        required: true
  workflow:
    - post_message_to_teams:
        do:
          io.cloudslang.base.http.http_client_post:
            - url: "${webhook_url}"
            - auth_type: 'anonymous'
            - body: >
                ${'{"text": "' + message + '"}'}
            - content_type: 'application/json'
            - trust_all_roots: 'true'
            - x_509_hostname_verifier: allow_all
        navigate:
          - SUCCESS: SUCCESS
          - FAILURE: on_failure
  results:
    - SUCCESS
    - FAILURE

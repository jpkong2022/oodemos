namespace: DemoUseCases
flow:
  name: add_user
  inputs:
    - username
  workflow:
    - Create_Local_User:
        do_external:
          a3482713-4f1c-413a-a7a8-d00211079a50:
            - newUsername: '${username}'
            - newPassword:
                value: ********
                sensitive: true
            - newDescription: '${username}'
        navigate:
          - success: SUCCESS
          - failure: FAILURE
  results:
    - SUCCESS
    - FAILURE

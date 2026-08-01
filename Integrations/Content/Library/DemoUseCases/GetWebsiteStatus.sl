namespace: DemoUseCases
flow:
  name: GetWebsiteStatus
  workflow:
    - verify_url_is_accessible:
        do:
          io.cloudslang.base.http.verify_url_is_accessible:
            - url: 'https://google.com'
        navigate:
          - SUCCESS: SUCCESS
          - FAILURE: on_failure
  results:
    - FAILURE
    - SUCCESS
# Detect Discrepancy

This Service Object is intended for internal use by HeyJobs to detect discrepancies between
Local campaigns and remote ads.

## Prerequisite

Make sure that you install `Ruby v2.5`

## Development

#### Clone the source

```shell
git clone https://github.com/Maghraby/detect_discrepancy.git
```

#### Installing

Running this command will install all required gems.
```shell
cd detect_discrepancy
./bin/setup
```

#### Console

```shell
./bin/console
```

#### Running

```ruby
./bin/console
detect = Detect.run
```

Check changes:
```ruby
detect.changes
```

Check errors:
```ruby
detect.errors
```


#### Service output format

```ruby
detect.changes
```

- When there is no discrepancy between local and remote. 
```ruby
[]
```

- When there is a discrepancy:
    - Between status or description of local and remote Campaign.
    ```ruby
    [
        {
            remote_reference: '2',
            discrepancies: [
                {
                    status: {
                        remote: 'disabled',
                        local: 'active'
                    }
                },
                {
                    ad_description: {
                        remote: 'Description for campaign 13',
                        local: 'Description for campaign 50'
                    }
                }
            ]
        },
        {
            remote_reference: '3',
            discrepancies: [
                {
                    ad_description: {
                        remote: 'Description for campaign 3',
                        local: 'Description for campaign 33'
                    }
                }
            ]
        }
    ]
    ```
    - When there is a remote Campaign without a matching local one. 
    ```ruby
    [
        {
            remote_reference: '2',
            discrepancies: [
                {
                    status: {
                        remote: 'enabled',
                        local: 'deleted'
                }
                },
                {
                    ad_description: {
                        remote: 'Description for campaign 13',
                        local: nil
                    }
                }
            ]
        }
    ]
    ```
    - When there is a local Campaign without a matching remote one.
    ```ruby
    [
        {
            remote_reference: '2',
            discrepancies: [
                {
                    status: {
                        remote: nil,
                        local: 'active'
                    }
                },
                {
                    ad_description: {
                        remote: nil,
                        local: 'Description for campaign 13'
                    }
                }
            ]
        }
    ]
    ```

```ruby
detect.errors
```

If no error:

```ruby
[]
```
When there are errors:

```ruby
[#<Errors::RemoteAdFetchError: Error while fetching data from url with error_message_here>]
```

#### Configurable

There are three configurable keys:
- REMOTE_AD_URL

  You can change the remote add URL.
  Example:

    ```shell
  REMOTE_AD_URL='https://mockbin.org/bin/fcb30500-7b98-476f-810d-463a0b8fc3df' bin/console
    ```
    ```ruby
  detect = Detect.run
  ...
    ```
- MAPPING_KEYS

    You can pass the mapping keys that you want this service to detect.
    Example:

    ```shell
    MAPPING_KEYS="{\"status\":\"status\",\"ad_description\":\"description\"}" ./bin/console
    ```
    ```ruby
    detect = Detect.run
    ...
    ```

    you can add keys as much you want ;).

- MAPPING_VALUES

    For keys that have different values from remote_ad and local campaign.
    Example:

    ```shell
    MAPPING_VALUES="{\"status\":{\"active\":\"enabled\",\"paused\":\"disabled\"}}" ./bin/console
    ```
     ```ruby
    detect = Detect.run
    ...
     ```
     This will map status key with values: enabled to active and disabled to paused.

#### Testing


```shell
rspec
```
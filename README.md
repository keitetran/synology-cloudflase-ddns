# Synology Cloudflare DDNS Script 📜
The is a script to be used to add [Cloudflare](https://www.cloudflare.com/) as a DDNS to [Synology](https://www.synology.com/) NAS. This is a modified version [script](https://gist.github.com/tehmantra/f1d2579f3c922e8bb4a0) from [Michael Wildman](https://gist.github.com/tehmantra). The script used an updated API, Cloudflare API v4.

```
You not need login to SSH, only need login to DMS
```

- Login to your DSM
- Create new task `Control Panel > Task Scheduler > Create > Schedule Task > User-defined Script`
  - Gernal settings: 
    - Task: `Synology CloudFlase setup`
    - User: `Root`
    - Uncheck to `Enabled this task`
  - Task setting
    - Add this code to `Run command` (* You can check or modify code at URL)
      ```bash
        #!/bin/sh

        # File URL
        FILE_URL="https://raw.githubusercontent.com/keitetran/synology-cloudflase-ddns/master/cloudflareddns.sh"

        # Download file 
        wget "$FILE_URL" -O /sbin/cloudflaredns.sh && chmod +x /sbin/cloudflaredns.sh

        # Modify setting file 
        cat >> /etc.defaults/ddns_provider.conf << 'EOF'
        [Cloudflare]
                modulepath=/sbin/cloudflaredns.sh
                queryurl=https://www.cloudflare.com/
        EOF
      ```
  - Back to orverview and select this task then click to `RUN`
  - You can delete this task or keep it because you was disabled task at first step

- Go to `Control Panel > External Access > DDNS > Add`
  - Service provider: `Cloudflare`
  - Hostname: `RECODE_TYPE DOMAIN ZONE_ID RECORD_ID TTL PROXY`
    - Keep that with space charactor
    - Example: `A my-nas.com 061ac5sabc60ba 73ccs728917c9d5c 1 true`
  - Username/Email: Your cloudflase username or email
  - Password: Your cloudflase API key

You can read the [Cloudflare API documentation v4](https://api.cloudflare.com/#dns-records-for-a-zone-update-dns-record) for more details.

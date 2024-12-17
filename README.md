# Hashicorp Vault Docker Compose

This is a simple repo for setting up Hashicorp Vault using Docker Compose.

## Pre-reqs

- [Docker](https://docs.docker.com/engine/install/)

- [Certbot](https://certbot.eff.org/instructions)

- [Vault CLI](https://developer.hashicorp.com/vault/docs/install)

## Using Certbot to get a certificate

Below are the steps needed to get a cert for a FQDN.

1. Install certbot

    ```bash
    sudo install certbot
    ```
2. Export the `DOMAIN_NAME` as an environment variable and validate it.

    ```bash
    export DOMAIN_NAME=""
    echo $DOMAIN_NAME
    ```

3. Using manual DNS validation generate the cert.

    ```bash
    certbot certonly --manual --preferred-challenges dns -d "$DOMAIN_NAME"
    ```

4. Once the prompt for DNS validation gives a key value pair add the given TXT record to your Domain.

5. After the record has been added check to see if you can return the record using nslookup.

    ```bash
    nslookup -type=TXT _acme-challenge.$DOMAIN_NAME
    ```

6. Copy the certs to the given Vault folders.
    
    ```bash
    cp /etc/letsencrypt/live/$DOMAIN_NAME/{fullchain.pem, privkey.pem} ./vault/certs/
    ```
7. Validate certs have correct permissions.

    ```bash
    sudo chmod 400 ./vault/certs/fullchain.pem ./vault/certs/privkey.pem
    ```

## Configuring Vault

1. Within the `.env` file update the `DOMAIN_NAME` variable.

2. Since HCL can not use environment variable substitution, you'll also need to update ${DOMAIN_NAME} in `config/config.hcl`.

    ```hcl
    api_addr = "https://${DOMAIN_NAME}:8200"
    cluster_addr = "https://${DOMIAN_NAME}:8201"
    ```

## Running Vault

1. Run the docker compose file.

    ```bash
    docker compose up -d
    ```

2. Validate that pod is running.

    ```bash
    docker ps -a
    ```

3. Exec into the Vault docker container.

    ```bash
    docker exec -it vault /bin/sh
    ```

4. You need to initilize the Vault server.

    ```bash
    vault operator init
    ```

5. Copy the output and store these keys. You'll need them to unseal Vault both now and in the future. The root key is also important as it is the super admin for the Vault instance.

6. Now unseal the Vault by running the following command three times with three different keys.

    ```bash
    vault operator unseal
    ```

7. Check the status that Vault is now unsealded.

    ```bash
    vault status
    ```

## Connect to Vault using Vault CLI

1. Set `VAULT_ADDR` on your local machine.
   
   ```bash
   export VAULT_ADDR="https://vault1.poc.thecloudgarage.com:8200"
   ```

2. Check the Vault status to see you're able to communicate.

    ```bash
    vault status
    ```

3. Status should look like the following.

    ```bash
    Key                Value
    ---                -----
    Seal Type          shamir
    Initialized        true
    Sealed             false
    Total Shares       0
    Threshold          0
    Unseal Progress    0/0
    Unseal Nonce       n/a
    Version            1.18.2
    Build Date         2024-11-20T11:24:56Z
    Storage Type       raft
    HA Enabled         true
    ```

4. Login in using the root key.

    ```bash
    vault login
    ```
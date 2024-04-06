# ONETIME SECRET - v0.13.0-RC1 (2024-04-05)

### **Initial release candidate with Ruby 3+ support: [v0.13.0-RC1](https://github.com/onetimesecret/onetimesecret/releases/tag/v0.13.0-RC1).**

_See the [v0.12.0](https://github.com/onetimesecret/onetimesecret/releases/tag/v0.12.0) for the final release with Ruby 2.6.8._

---


*Keep passwords and other sensitive information out of your inboxes and chat logs.*

## What is a Onetime Secret? ##

A one-time secret is a link that can be viewed only once. A single-use URL.

<a class="msg" href="https://onetimesecret.com/">Give it a try!</a>

## Why would I want to use it? ##

When you send people sensitive info like passwords and private links via email or chat, there are copies of that information stored in many places. If you use a one-time link instead, the information persists for a single viewing which means it can't be read by someone else later. This allows you to send sensitive information in a safe way knowing it's seen by one person only. Think of it like a self-destructing message.

## How to install

### System Requirements

_tbd_

### Installation - Docker Compose

### Installation - Manual



#### Setup Onetime Secret

```bash
  export user=CHANGEME
  #
  # Or use your current username:
  #   export user=$USER
  #
  sudo adduser $user

  sudo su - $user
  git clone https://github.com/onetimesecret/onetimesecret.git
  cd onetimesecret
  bundle install --frozen
  bin/ots init
  sudo mkdir /etc/onetime /var/log/onetime /var/run/onetime /var/lib/onetime
  sudo chown $user /etc/onetime /var/log/onetime /var/run/onetime /var/lib/onetime
  chmod -R o-rwx /etc/onetime /var/lib/onetime
  cp -rp etc/* /etc/onetime/
```

## Development

### Setup

```bash
  git clone git@github.com:onetimesecret/onetimesecret.git
  cd onetimesecret

  # Create and update your local config files
  cp -p etc/config.example etc/config
  cp -p etc/redis.conf.example etc/redis.conf
  cp -p .env.example .env

  bundle install
  bin/ots init

  # Start the redis server and then start the app
  ONETIME_DEBUG=true bundle exec thin -e dev start
```

If you have any issues, check the Dockerfile for clues or please let us know by [opening an issue](https://github.com/onetimesecret/onetimesecret/issues/new).

### About git cloning

The instructions above suggest cloning via the `https` URI. You can also clone using the SSH URI if you have a github account (which is generally more convenient, but specific to github).

**With a github account**
```bash
  ssh -T git@github.com
  Hi delano! You've successfully authenticated, but GitHub does not provide shell access.
```

**Without a github account**
```bash
  ssh -T git@github.com
  Warning: Permanently added the RSA host key for IP address '0.0.0.0/0' to the list of known hosts.
  git@github.com: Permission denied (publickey).
```

*NOTE: you can also use the etc directory from here instead of copying it to the system. Just be sure to secure the permissions on it*

```bash
  chown -R ots ./etc
  chmod -R o-rwx ./etc
```

### Update the configuration

1. `/etc/onetime/config`
  * Update your secret key
    * Store it in your password manager because it's included in the secret encryption
  * Add or remove locales
  * Update the SMTP or SendGrid credentials
  * Update the from address
    * it's used for all sent emails
  * Update the the limits at the bottom of the file
    * These numbers refer to the number of times each action can occur for unauthenticated users.
    * If you would like to increase the limits for authenticated users too, see (lib/onetime.rb](https://github.com/onetimesecret/onetimesecret/blob/main/lib/onetime.rb#L261-L279)
1. `/etc/onetime/redis.conf`
  * The host, port, and password need to match
1. `/etc/onetime/locale/*`
  * Optionally you can customize the text used throughout the site and emails
  * You can also edit the `:broadcast` string to display a brief message at the top of every page

### Running

There are many way to run the webapp, just like any Rack-based app. The default web server we use is [thin](https://github.com/macournoyer/thin).

**To run locally:**

```bash
  bundle exec thin -e dev -R config.ru -p 7143 start
```

**To run on a server:**

```bash
  bundle exec thin -d -S /var/run/thin/thin.sock -l /var/log/thin/thin.log -P /var/run/thin/thin.pid -e prod -s 2 restart
```

**To run with docker:**

```bash
  docker compose up
  open http://localhost:7143
```

## Generating a global secret

We include a global secret in the encryption key so it needs to be long and secure. One approach for generating a secret:

```bash
  dd if=/dev/urandom bs=20 count=1 | openssl sha256
```

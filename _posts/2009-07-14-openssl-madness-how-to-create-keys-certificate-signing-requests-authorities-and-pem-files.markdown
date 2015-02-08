---
layout: post
title: Creating SSL keys, CSRs, self-signed certificates, and .pem files.
excerpt: "A simple run-down on generating SSL certificates from beginning to end."
---
### What is the whole darned process?
Well that's a good question. For my purposes, this is what I need to know:

1. Create a Private Key. These usually end in the file extension "key" If you
already have one, don't worry - it's cool, we'll be using that one.
2. Create a Certificate Signing Request. These usually end in the extension
"csr", and you send it to the certificate authority to generate a certificate.
3. If you're not going to be using an existing service (usually for pay) as
a certificate authority, you can create your own Certificate Authority, or
self-sign your certificate.
4. Submit your CSR to the CA and get the results. If you're doing it yourself,
I'll tell you how. The CA creates a Certificate file, which ends in ".crt".
5. Take the whole collection of files, keep them somewhere safe, and mash them
together to create your PEM file (this is usually just used for email.)

So. Let's get started, eh?

### Step Zero: Basic Assumptions

- I'll assume your domain name is domain.tld.
- I'll assume you have OpenSSL installed.
- I'll assume that you are running some form of Linux. I use Debian.

### Step One: Create your Private Key
Ok, here you're going to create your key - and treat is as such. You should
keep this private, and not shared with anyone.

Now, you have a couple of options here - the first is to create your private
key with a password, the other is to make it without one. If you create it
with a password, you have to type it in every time your start any server that
uses it.

**Important:** If you create your private key with a password,
you can remove it later. I recommend creating your private key with a password,
and then removing it every time you need to use it. When you're done with the
key without a password, delete it so it isn't a security risk.

#### Create your Private key **with** a password

    openssl genrsa -des3 -out domain.tld.encrypted.key 1024

#### Create your Private key **without** a password

    openssl genrsa -out domain.tld.key 1024

If you created your private key with a password, you'll want to complete the
rest of the steps using a decrypted private key - else you'll have to type in
your password every time you use the certificate (ie: every time you start a
daemon using that certificate.)

#### Remove the password and encryption from your private key
    openssl rsa -in domain.tld.encrypted.key -out domain.tld.key

### Step Two: Create a CSR
On this step you're going to create what you send to your Certificate
Authority. If you set a password with your Private Key, you'll enter it to
create the CSR. After you finish all these steps, you can delete your CSR.

#### Create your Certificate Signing Request

    openssl req -new -key domain.tld.key -out domain.tld.csr


### Step Three: Create your Certificate
You have three options here:
1. Self-signing - Easy, free, and quick. Not trusted by browsers.
2. Creating a certificate authority (CA) - Not difficult, but likely more
   effort. Still isn't trusted by browsers.
3. Paying a CA to create your certificate for you. Can be cheap ($20), pretty
   easy, and is trusted by browsers.

**My advice:** Self-sign your certificates for personal things, and pay for a
certificate if its public and important.

If you'd like to pay for someone to sign your certificates, do some research
and find which one you want to use. Next, find their instructions for
submitting your CSR file.

#### Self-Sign your Certificate

    openssl x509 -req -days 365 -in domain.tld.csr -signkey domain.tld.key -out domain.tld.crt

If you do happen to want to setup your own certificate authority, check these
resources out:

- <http://www.g-loaded.eu/2005/11/10/be-your-own-ca/>
- <http://codeghar.wordpress.com/2008/03/17/create-a-certificate-authority-and-certificates-with-openssl/>

### Step Four: Creating a PEM file

Many daemons use a PEM file. Directions on how to generate such a PEM file can
be hard to come by. I have had pretty good success with combining the .key and
the .crt file together:

    cat domain.tld.key domain.tld.crt > domain.tld.pem

### Disclaimer

I am not an expert with SSL, which is exactly why I created this. This may not
be accurate, YMMV, etc. Be careful. Also: Your .key is private. Keep that safe,
with appropriate permissions. Make sure nobody else can access it, and do not
give it away to anyone.

### Sources
Just a thank-you to everyone that was kind enough to document this process.

- <http://www.rapidssl.com/ssl-certificate-support/generate-csr/apache_mod_ssl.htm>
- <http://www.akadia.com/services/ssh_test_certificate.html>

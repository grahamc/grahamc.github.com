--- 
wordpress_id: 216
layout: post
title: Rackspace CloudSites Review
wordpress_url: http://iamgraham.net/?p=216
---
<div id="_mcePaste" style="position: absolute; left: -10000px; top: 0px; width: 1px; height: 1px; overflow-x: hidden; overflow-y: hidden;">I’m investigating using Rackspace CloudSites as a replacement for 90% of my, and my client’s hosting needs. This may come as a disappointment to some, but I’m finding myself out of time for this sort of work. The clients I began migrating to the CloudSites service were experiencing repeated issues with their service.</div>
<!--more-->
<div id="_mcePaste" style="position: absolute; left: -10000px; top: 0px; width: 1px; height: 1px; overflow-x: hidden; overflow-y: hidden;">Until my clients’ reported problems to me, I hadn’t bothered to log into the client interface. When I did, I was appalled by the state of affairs of what they call a “Control Panel” (though I prefer to use the term “Password Checker”, as that is nearly the only functionality it provides.) In general,I would be offended if a web host provided me this interface.</div>
<div id="_mcePaste" style="position: absolute; left: -10000px; top: 0px; width: 1px; height: 1px; overflow-x: hidden; overflow-y: hidden;">My first issue I discovered was the difficulty to change the website login password. After blindly clicking links for several minutes, I found that I was able to change the password for the FTP account of the same name. Coincidently, changing the password there also updates the password for the website user.</div>
<div id="_mcePaste" style="position: absolute; left: -10000px; top: 0px; width: 1px; height: 1px; overflow-x: hidden; overflow-y: hidden;">On the topic of FTP, it appears that a client is unable to add additional FTP accounts. That’s ludicrous. I assume this implies that in order for a user to have an FTP account, they have to have access to the web interface, and that isn’t acceptable. Several of my clients require a limited-use FTP account for distribution. Oh, did I mention they made a grammatical error? “An username”…</div>
<div id="_mcePaste" style="position: absolute; left: -10000px; top: 0px; width: 1px; height: 1px; overflow-x: hidden; overflow-y: hidden;">Clients also can’t add additional contacts to their account. Again, this is likely involved with the issue of access to the administrative screen.</div>
<div id="_mcePaste" style="position: absolute; left: -10000px; top: 0px; width: 1px; height: 1px; overflow-x: hidden; overflow-y: hidden;">Nor can they create email addresses? Now that’s obnoxious I guess, but the kicker is that they can delete them if they choose.</div>
<div id="_mcePaste" style="position: absolute; left: -10000px; top: 0px; width: 1px; height: 1px; overflow-x: hidden; overflow-y: hidden;">But at least they can add cronjobs...</div>
<div id="_mcePaste" style="position: absolute; left: -10000px; top: 0px; width: 1px; height: 1px; overflow-x: hidden; overflow-y: hidden;">The final few things are more minor bugs or inconveniences – however definitely present.</div>
<div id="_mcePaste" style="position: absolute; left: -10000px; top: 0px; width: 1px; height: 1px; overflow-x: hidden; overflow-y: hidden;">For one, a client can’t add additional websites to their account. I can see this making a little bit of sense, but they should at least be able to start the process. It’s no skin off my nose if they want to give me more money.</div>
<div id="_mcePaste" style="position: absolute; left: -10000px; top: 0px; width: 1px; height: 1px; overflow-x: hidden; overflow-y: hidden;">And finally, their statistics are wrong. They claim that I haven’t used any bandwidth, no DiskSpace, and haven’t even run a single CPU compute cycle. The account I’m referring to has been intentionally active, to test their service. On top of those, when I setup the account – I immediately turned on web statistics. A few days later, they were still listed as “Unavailable” – apparently something went wrong setting them up the first time, which caused those days of data to be lost.</div>
I’m investigating using Rackspace CloudSites as a replacement for 90% of my, and my client’s hosting needs. This may come as a disappointment to some, but I’m finding myself out of time for this sort of work. The clients I began migrating to the CloudSites service were experiencing repeated issues with their service.

Until my clients’ reported problems to me, I hadn’t bothered to log into the client interface. When I did, I was appalled by the state of affairs of what they call a “Control Panel” (though I prefer to use the term “Password Checker”, as that is nearly the only functionality it provides.) In general,I would be offended if a web host provided me this interface.

My first issue I discovered was the difficulty to change the website login password. After blindly clicking links for several minutes, I found that I was able to change the password for the FTP account of the same name. Coincidently, changing the password there also updates the password for the website user.

On the topic of FTP, it appears that a client is unable to add additional FTP accounts. That’s ludicrous. I assume this implies that in order for a user to have an FTP account, they have to have access to the web interface, and that isn’t acceptable. Several of my clients require a limited-use FTP account for distribution. I asked tech support to see if that could be enabled so I didn't need to manage their FTP accounts, however to no avail - that isn't possible at the moment. Maybe they'll figure it out later.

[caption id="attachment_201" align="aligncenter" width="300" caption="Can&#39;t add any users here..."]<a href="http://iamgraham.net/wp-content/uploads/2009/11/permissions-typo.png"><img class="size-medium wp-image-201" title="FTP Permissions - An Username?" src="http://iamgraham.net/wp-content/uploads/2009/11/permissions-typo-300x101.png" alt="An Username?" width="300" height="101" /></a>[/caption]

Clients also can’t add additional contacts to their account. Again, this is likely involved with the issue of access to the administrative screen.

Nor can they create email addresses? Now that’s obnoxious I guess, but the kicker is that they can delete them if they choose. I'm guessing... no, I'm hoping that's a bug, but it is certainly the case for the moment, and missing this is a pretty serious strike against them in my books.

[caption id="attachment_212" align="aligncenter" width="300" caption="I can&#39;t add &#39;em, but I can delete &#39;em!"]<a href="http://iamgraham.net/wp-content/uploads/2009/11/Screen-shot-2009-11-18-at-11.26.53-PM.png"><img class="size-medium wp-image-212" title="I can't add 'em, but I can delete 'em!" src="http://iamgraham.net/wp-content/uploads/2009/11/emails1-300x95.png" alt="I can't add 'em, but I can delete 'em!" width="300" height="95" /></a>[/caption]

<strong>Update 11/19/2009:</strong> As noted below, adding email accounts is possible via an obscure path.

But at least they can add cronjobs...

[caption id="attachment_207" align="aligncenter" width="300" caption="Woohoo! I can run Cron-Jobs!"]<a href="http://iamgraham.net/wp-content/uploads/2009/11/crontabs1.png"><img class="size-medium wp-image-207" title="I can't add email or FTP, but I can add cronjobs!" src="http://iamgraham.net/wp-content/uploads/2009/11/crontabs1-300x83.png" alt="I can't add email or FTP, but I can add cronjobs!" width="300" height="83" /></a>[/caption]

The final few things are more minor bugs or inconveniences – however definitely present.

For one, a client can’t add additional websites to their account. I can see this making a little bit of sense, but they should at least be able to start the process. It’s no skin off my nose if they want to give me more money.

And finally, their statistics are wrong. They claim that I haven’t used any bandwidth, no DiskSpace, and haven’t even run a single CPU compute cycle. The account I’m referring to has been intentionally active, to test their service. On top of those, when I setup the account – I immediately turned on web statistics. A few days later, they were still listed as “Unavailable” – apparently something went wrong setting them up the first time, which caused those days of data to be lost.

Unfortunately this seems to be a case of Rackspace's terrible interface, and it's a good thing they have their Fanatical Support to back it up. I'm severely disappointed by the interface of CloudSites. I would be pleased to use their services, as they offer more than what many of my, and my clients' sites require, however their interface is doing them a very, very serious disfavor. On that note, if they were to release a public API which I could create a functional interface for, I would look again.

Disappointing, too - I had high hopes.

<strong>Update 11/19/2009: </strong>I've found that while I cannot add email accounts in the "Email Accounts" tab, if I go into "General Settings", scroll down to "Website Features" (note: not the "Features" tab), I can (next to Email Accounts) choose to View List

[caption id="attachment_226" align="aligncenter" width="300" caption="Going to General Settings -&gt; Website Features -&gt; Add New, I can add an email."]<a href="http://iamgraham.net/wp-content/uploads/2009/11/adding-an-email.png"><img class="size-medium wp-image-226" title="Adding An Email" src="http://iamgraham.net/wp-content/uploads/2009/11/adding-an-email-300x103.png" alt="Going to General Settings -&gt; Website Features -&gt; Add New, I can add an email." width="300" height="103" /></a>[/caption]

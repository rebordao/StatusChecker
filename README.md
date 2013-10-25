# Status Checker

## Description

This library runs (via a cronjob) every `x` minutes and checks if a server is online or down. If it's down, sends an email to the people in charge of the machine and, when the issue is fixed, reports the new status via email.

## Dependencies

This library was tested in Debian 7.2 Wheezy. It requires bash 4.0 (or higher), sendemail and SMARTTLS authentication. The last two can be installed by doing:

> sudo apt-get install sendemail libnet-ssleay-perl libio-socket-ssl-perl

## Usage

1. Place the folder `statusChecker` in your home directory. Copy `config.txt.EXAMPLE` into a file called `config.txt`.

2. Edit `config.txt` such that it contains the IPs of the servers that you want to monitor and the email addresses of the people in charge of them. For example:

	HOSTS["`192.168.11.30`"]="`person1@gmail.com` `person2@gmail.com`"

	Adds the IP `192.168.11.30` to the list of servers to monitor and, if the server is down, an email will be sent to `person1@gmail.com` and `person2@gmail.com`.

3. Create a cron job to run the script every `x` minutes. For example open the crontab file by typing `crontab -e` and add:  

	*/5 * * * * ~/statusChecker/statusChecker.sh

	This sets the script to execute every 5 minutes.

4. Before you go into production with this library, please confirm that the file `hostsDown.txt` is empty.

	cat ~/statusChecker/hostsDown.txt

## Troubleshooting

If the emails aren't sent and you get the message `invalid SSL_version specified at /usr/share/per15/IO/Socket/SSL.pm line 332`, then change line 1907 of `/usr/bin/sendemail` from `SSLv3 TLSv1` to `SSLv3`.

## Enhancements

What about if the cron job fails and you don't notice? Wouldn't be nice to receive an email with such notification?

The email capability of `Cron` solves this issue by emailing the execution status of each job. To have it working install and configure a mail system like [Postfix](https://wiki.debian.org/Postfix?highlight=%28%28Postfix%29%29) and add to the `crontab` the field `MAILTO="<admin's email address>"`.

Then for each job you will get an email but soon this feels like spam. It's much better to receive an email only when the job execution fails. This can be achieved by using a cron wrapper and my choice was [Cronwrap](https://github.com/Doist/cronwrap). Check the website for details about how to install it and then use it to call the `statusChecker`. This last step can be done by substituting the crontab line of step 3 by the following:
    
*/5 * * * * /usr/local/bin/cronwrap -c "~/statusChecker/statusChecker.sh" -e `<admin's email address>`

Note that now the field `MAILTO="<admin's email address>"` in `crontab` became redundant and can be removed.

## License

Distributed under a MIT License. Check `license.txt` for details.

## Credits

This utility was made in November 2013 by:

- Antonio Rebordao antonio.rebordao@gmail.com

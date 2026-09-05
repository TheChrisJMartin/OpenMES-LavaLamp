sudo scp -i murder ./target/openmes.war root@murder.donotpassgo.co.uk:/var/lib/tomcat10/webapps/openmes.war
sudo ssh -i murder -t root@murder.donotpassgo.co.uk 'service tomcat10 restart; bash -l'

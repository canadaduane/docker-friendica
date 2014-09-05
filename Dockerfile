FROM tutum/lamp:latest
MAINTAINER Fabrix Xm <fabrix.xm@gmail.com>

RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get -y upgrade && DEBIAN_FRONTEND=noninteractive apt-get -y install php5-gd php5-curl && DEBIAN_FRONTEND=noninteractive apt-get -y clean

RUN a2enmod rewrite && sed -i "s/AllowOverride None/AllowOverride All/g" /etc/apache2/sites-enabled/*

RUN rm -fr /app && git clone https://github.com/friendica/friendica.git /app
RUN chmod 777 /app/view/smarty3
RUN git clone https://github.com/friendica/friendica-addons.git /app/addon

ADD import_sql.sh /import_sql.sh
ADD setup.sh /setup.sh
ADD run.sh /run.sh
RUN chmod 755 /*.sh

VOLUMES ["/var/lib/mysql", "/logs"]

ENV DATABASE friendica

EXPOSE 80 3306
CMD ["/run.sh"]

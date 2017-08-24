FROM tomcat:7-jre7

COPY ./sod.war /usr/local/tomcat/webapps/sod.war
ENV JPDA_ADDRESS=8000
ENV JPDA_TRANSPORT=dt_socket

CMD ["catalina.sh", "jpda", "run"]  

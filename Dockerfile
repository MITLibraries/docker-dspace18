FROM debian:wheezy
MAINTAINER Mike Graves <mgraves@mit.edu>

RUN apt-get update && apt-get install -y \
    curl \
    postgresql-client \
    openjdk-6-jre \
    maven \
    ant

ADD startup.sh /usr/local/bin/startup.sh
RUN chmod +x /usr/local/bin/startup.sh


# Install Tomcat 7
ENV TOMCAT_VERSION 7.0.62
ENV CATALINA_HOME /usr/local/tomcat
ENV PATH $CATALINA_HOME/bin:$PATH

RUN mkdir -p ${CATALINA_HOME}
RUN cd ${CATALINA_HOME} && \
    curl -L https://www.apache.org/dist/tomcat/tomcat-7/v${TOMCAT_VERSION}/bin/apache-tomcat-${TOMCAT_VERSION}.tar.gz | \
    tar xz --strip-components=1


# Install DSpace
ENV DSPACE_VERSION 1.8.3
ENV INSTALL_DIR /dspace
ENV SOURCE_DIR /tmp/DSpace-dspace-${DSPACE_VERSION}
ENV BUILD_DIR ${SOURCE_DIR}/dspace/target/dspace-${DSPACE_VERSION}-build

RUN cd /tmp && curl -L https://github.com/DSpace/DSpace/archive/dspace-${DSPACE_VERSION}.tar.gz | tar xz

RUN sed -i "s,^dspace.dir.*,dspace.dir = ${INSTALL_DIR}", \
    ${SOURCE_DIR}/dspace/config/dspace.cfg

RUN mkdir ${INSTALL_DIR}
RUN cd ${SOURCE_DIR}/dspace && mvn package
RUN cd ${BUILD_DIR} && \
    ant init_installation && \
    ant init_configs && \
    ant update_code && \
    ant init_geolite && \
    ant -Dwars=true copy_webapps

RUN cp -R ${INSTALL_DIR}/webapps/*.war ${CATALINA_HOME}/webapps


# Start Tomcat
EXPOSE 8080
ENTRYPOINT ["/usr/local/bin/startup.sh"]
CMD ["catalina.sh", "run"]


# sparx-gwells
FROM openshift/base-centos7

MAINTAINER Gary Wong <garywong@gov.bc.ca>

ENV BUILDER_VERSION 1.1

LABEL io.k8s.description="Platform for publishing Sparx EA Generated content online" \
      io.k8s.display-name="sparx-gwells 0.1.0" \
      io.openshift.expose-services="8080:http" \
      io.openshift.tags="gwells,Ground Water, Wells, Sparx, Enterprise Architect"

# Install apache and add our content
RUN yum install -y httpd && yum clean all -y
ADD gwells /var/www/html

# Configure apache to use port 8080 (this simplifies some OSP stuff for us)
RUN sed -i 's/Listen 80/Listen 8080/' /etc/httpd/conf/httpd.conf
RUN sed -i 's/DirectoryIndex index.html/DirectoryIndex index.htm/' /etc/httpd/conf/httpd.conf


# sets io.openshift.s2i.scripts-url label that way, or update that label
LABEL io.openshift.s2i.scripts-url=image:///usr/libexec/s2i
COPY ./s2i/bin/ /usr/libexec/s2i

# Setup privileges for both s2i code insertion, and openshift arbitrary user
RUN mkdir -p /opt/app-root/src
ENV APP_DIRS /opt/app-root /var/www/ /run/httpd/ /etc/httpd/logs/ /var/log/httpd/
RUN chown -R 1001:1001 $APP_DIRS
RUN chgrp -R 0 $APP_DIRS
RUN chmod -R g+rwx $APP_DIRS

WORKDIR /opt/app-root/src

# This default user is created in the openshift/base-centos7 image
USER 1001

# Set the default port for applications built using this image
EXPOSE 8080

# Set the default CMD for the image
CMD /usr/sbin/httpd -D FOREGROUND

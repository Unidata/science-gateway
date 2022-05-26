from rockylinux:8.5.20220308

###
# Update the system. Install stuff.
###

# Install repo: Extra Packages for Enterprise Linux
RUN yum upgrade -y && yum install -y epel-release

# Desired packages for basic use
RUN yum install -y sudo man man-pages vim nano git wget unzip ncurses procps \
	htop python3 telnet openssh openssh-clients openssl findutils

###
# Create rocky user account and add to sudoers file
###

RUN useradd -ms /bin/bash rocky
ENV HOME /home/rocky
ENV USER rocky
RUN echo "rocky ALL=NOPASSWD: ALL" >> /etc/sudoers
WORKDIR $HOME
USER rocky

CMD echo 'Build successful! For interactive mode, run as "docker run -it unidata/rocky /bin/bash"'

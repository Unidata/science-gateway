FROM rockylinux:9.3.20231119

# Update system and install EPEL repository
RUN dnf upgrade -y && dnf install -y epel-release

# Install desired packages
RUN dnf install -y \
    sudo man man-pages vim nano git wget unzip ncurses procps-ng \
    htop python3 telnet openssh openssh-clients openssl findutils diffutils && \
    dnf clean all

# Default command uses JSON array syntax for signal-safe execution
CMD ["/bin/echo", "Build successful! For interactive mode, run as: docker run -it unidata/rockylinux /bin/bash"]

# image to use
FROM mysql:5.6

# better my.cnf
COPY ./projects/drupalgap/d7dg7/mysql/default.my.cnf /etc/mysql/my.cnf

# add .my.cnf
COPY ./projects/drupalgap/d7dg7/mysql/default.dot.my.cnf /root/.my.cnf

# apt-get what we need
RUN apt update && apt install -y \
  telnet \
  vim \
  nano \
  net-tools \
  wget

# root .bashrc
RUN echo "PS1='\[\e[31m\]\u\[\e[m\]@\h:\w\$ '" >> /root/.bashrc
RUN echo "alias ll='ls -la'" >> /root/.bashrc
RUN echo "export TERM=xterm" >> /root/.bashrc

FROM phusion/passenger-full:latest
MAINTAINER SaKKo "saklism@gmail.com"
ENV HOME /root
CMD ["/sbin/my_init"]
EXPOSE 80
# RUN apt-get install libpq-dev tmux vim

RUN mkdir -p /tmp
WORKDIR /tmp
ADD Gemfile Gemfile.lock ./
RUN chown -R app.app /tmp
RUN gem install bundler
RUN bundle install --jobs 40 --retry 10

RUN rm -f /etc/service/nginx/down
RUN rm /etc/nginx/sites-enabled/default
ADD webapp.conf /etc/nginx/sites-enabled/webapp.conf
ADD secret_key.conf /etc/nginx/main.d/secret_key.conf
ADD gzip_max.conf /etc/nginx/conf.d/gzip_max.conf
ADD postgres-env.conf /etc/nginx/main.d/postgres-env.conf

RUN mkdir -p /home/app/webapp
WORKDIR /home/app/webapp
ADD . ./
ADD config/database.docker.yml /home/app/webapp/config/database.yml
RUN chown -R app:app /home/app/webapp
RUN setuser app rake assets:clobber
RUN setuser app rake assets:precompile

# RUN mkdir -p /home/app/webapp/log
# RUN touch /home/app/webapp/log/production.log
# RUN chown -R app:app /home/app/webapp/log
# RUN chmod 0664 /home/app/webapp/log/production.log

RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

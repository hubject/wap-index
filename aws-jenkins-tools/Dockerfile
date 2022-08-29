FROM nginx:stable
COPY ./d /usr/share/nginx/html/
COPY ./index.html /usr/share/nginx/html/
COPY ./vue.min.js /usr/share/nginx/html/
COPY ./nginx.conf /etc/nginx/
RUN \
   ln -sf /dev/stdout /var/log/nginx/access.log && \
   ln -sf /dev/stderr /var/log/nginx/error.log

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]

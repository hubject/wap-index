FROM nginx:stable
COPY ./dist/* /usr/share/nginx/html/
COPY ./nginx.conf /etc/nginx/
RUN \
   ln -sf /dev/stdout /var/log/nginx/access.log && \
   ln -sf /dev/stderr /var/log/nginx/error.log

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]

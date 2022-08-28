FROM openjdk:8-jdk-slim

ADD hbs2-portal-api.jar app.jar

# Our application runs on that port so allow hosts to bind to that port
EXPOSE 8198

ENV JAVA_OPTS="-XX:MinHeapFreeRatio=10 -XX:MaxHeapFreeRatio=20 -Xms75m -Xmx300m -Duser.timezone=UTC -Djavax.net.debug=handshake,data"
#ENV JAVA_OPTS="-XX:+UseG1GC -Duser.timezone=UTC -Djavax.net.debug=handshake,data"
ENV ALB_MS_HOST=""
ENV SPRING_PROFILE=aws-prod

ENV ENCRYPT_KEYSTORE_PASSWORD="8d!eE2x_9K"
ENV ENCRYPT_KEYSTORE_SECRET="Fsi_23e3!L"
ENTRYPOINT [ "sh", "-c", "exec java $JAVA_OPTS -Dspring.profiles.active=$SPRING_PROFILE -Djava.security.egd=file:/dev/./urandom -jar /app.jar" ]
#ENTRYPOINT [ "sh", "-c", "exec java $JAVA_OPTS -Dspring.profiles.active=native -Djava.security.egd=file:/dev/./urandom -Dserver.port=$PORT -jar -Dencrypt.keyStore.location=classpath:/server.jks -Dencrypt.keyStore.password=$ENCRYPT_KEYSTORE_PASSWORD -Dencrypt.keyStore.alias=defconfigkey -Dencrypt.keyStore.secret=$ENCRYPT_KEYSTORE_SECRET /app.jar" ]

#ENTRYPOINT [ "sh", "-c", "exec java $JAVA_OPTS -Dspring.profiles.active=$SPRING_PROFILE -Djava.security.egd=file:/dev/./urandom -jar /app.jar" ]

#ENV JAVA_OPTS="-XX:+UseG1GC -Duser.timezone=UTC -Djavax.net.debug=handshake,data"
##ENV ALB_MS_HOST=""
##ENV SPRING_PROFILE=aws-dev
#
#ENTRYPOINT [ "sh", "-c", "exec java $JAVA_OPTS -Dspring.profiles.active=$SPRING_PROFILE -Djava.security.egd=file:/dev/./urandom -jar /app.jar" ]

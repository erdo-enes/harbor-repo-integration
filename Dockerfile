FROM nginx:alpine

LABEL maintainer="Enes Erdogan" \
      project="jenkins-harbor-test" \
      description="Simple nginx image built by Jenkins and pushed to Harbor"

RUN rm -rf /usr/share/nginx/html/*

COPY index.html /usr/share/nginx/html/index.html

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]

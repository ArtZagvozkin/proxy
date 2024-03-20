FROM 3proxy/3proxy:latest
WORKDIR /usr/local/3proxy
COPY ./conf /usr/local/3proxy/conf
EXPOSE 57002
CMD ["3proxy", "/usr/local/3proxy/conf/3proxy.cfg"]

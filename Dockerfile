FROM ruby:2.5

RUN apt-get update && apt-get install -y r-base && apt-get install -y pandoc
RUN Rscript -e "install.packages('plotly', repos = 'http://cran.us.r-project.org')"

WORKDIR /usr/src/bosh-director-logs-parser
COPY logs_parser.rb plot_interactive.R ./

ENTRYPOINT ["./logs_parser.rb"]
CMD []

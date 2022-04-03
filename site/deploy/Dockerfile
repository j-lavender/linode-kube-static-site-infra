FROM --platform=linux/amd64 ubuntu:20.04 AS base
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
               ruby-full ruby-bundler python3 \
               git build-essential zlib1g-dev \
    && rm -rf /var/lib/apt/lists/* \
    && groupadd -g 1000 jekyll \
    && useradd -mu 1000 -g jekyll jekyll
USER jekyll
WORKDIR /home/jekyll
ENV GEM_HOME=/home/jekyll/gems \
    PATH="/home/jekyll/gems/bin:${PATH}"
COPY Gemfile Gemfile.lock ./
RUN bundle install

FROM base AS generate
COPY --chown=jekyll:jekyll . ./src
WORKDIR /home/jekyll/src
RUN bundle exec jekyll build --destination /home/jekyll/build --trace

FROM nginx:1.21-alpine
COPY ./deploy/default.conf /etc/nginx/conf.d/default.conf
COPY --from=generate /home/jekyll/build /usr/share/nginx/html
FROM ruby:3.2.3

# Install dependencies
RUN apt-get update -qq && apt-get install -y \
    build-essential \
    nodejs

# Set working directory
WORKDIR /app

# Copy Gemfile and Gemfile.lock
COPY Gemfile Gemfile.lock ./

# Install gems
RUN gem install jekyll bundler
RUN bundle install

# Copy the website source code
COPY . .

# Expose port 4000
EXPOSE 4000

# Default command to run
CMD ["bundle", "exec", "jekyll", "serve", "--host", "0.0.0.0"]
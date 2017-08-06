# Fixup titles of Pinboard-bookmarked tweets

Pinboard archives my favorited tweets, but I don't like the titles. This project fixes them:

* Fetch all pinboard bookmarks that are tweets
* Use the Twitter API to fetch the whole tweet
* Update the pinboard bookmark with the tweet as title

# Usage

1. Get the API token from the Pinboard [password](https://pinboard.in/settings/password) page and set it as environment variable.

        $ export PINBOARD_API_TOKEN=********

1. Run the tool:

        $ pinboard-fixup-tweets

# Docker Image

An automated build on the [docker hub](https://hub.docker.com/r/nerab/pinboard-fixup-tweets/) creates a new image tagged with `latest` upon a git push.

Optionally, you can build the image manually:

    # Build and tag as the latest version of the image
    $ docker build --tag nerab/pinboard-fixup-tweets:latest .

# Deployment

## Generate the run helper

* Install `lpass`
* Generate the deployment script `scripts/generate-run-script > scripts/run.sh`

If desired, you may run the container manually:

    $ docker run \
        --env PINBOARD_API_TOKEN=******** \
        --env TWITTER_CONSUMER_KEY=******** \
        --env TWITTER_CONSUMER_SECRET=******** \
        --name pinboard-fixup-tweets \
        nerab/pinboard-fixup-tweets

Change the environment variables to suit your preferences. The following environment variables are evaluated (in ascending order of preference):

## Start the container

Run the previously generated `scripts/run.sh`. This will generate a new container from the image and execute the `pinboard-fixup-tweets` tool once. The container will then stop.

In order to run the tool regularly, copy the cron script `scripts/` to `/etc/cron.hourly/`, e.g. with

```
docker-machine scp scripts/cronjob nr-docker:/etc/cron.hourly/pinboard-fixup-tweets
```

The environment variables were passed when running the container for the first time, so there is no need to pass them to `docker start` again.

## Logs

A container will not print its console messages to where it was started from. If you want to follow the execution, use `docker logs`:

    $ docker logs -f pinboard-fixup-tweets

## Update the container

```
docker pull nerab/pinboard-fixup-tweets

# This will fail in most cases because the container is only running once an hour
docker stop nerab/pinboard-fixup-tweets

docker rm nerab/pinboard-fixup-tweets
./scripts/run.sh
```

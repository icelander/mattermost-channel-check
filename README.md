# Mattermost Channel Check

In the event of an error in importing this script will verify that users are in the correct channels.

## Setup

0. Make sure you have Ruby installed
1. `cd` to this directory
2. Run `bundle` to install the required Gems
3. `cp sample.conf.yaml conf.yaml` and update `conf.yaml` with your Mattermost settings

## Run

```
./channel_check.rb import.json
```

Where `import.json` is the path to your file import. Because this works over the API it can be run on any machine that can access the Mattermost server. This will check all the users in the export file and verify that they're in the correct channels.

If a user isn't in a channel that's specified this will be printed to stdout. If you want the script to fix this automatically, run it with the `--apply` flag:

```
./channel_check.rb import.json --apply
```

All changes will be sent to stdout.
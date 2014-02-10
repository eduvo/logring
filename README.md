# Logring

One Logring to rule them all.

Under development. DO NOT USE (yet).

## Installation

Be sure you have a running default ruby and curl installed.

    curl -s -L https://raw.github.com/eduvo/logring/master/install | bash -s

or

    curl -s -L https://raw.github.com/eduvo/logring/master/install | bash -s -- --dest=./logring

Available options

    --dest    where to install logring config and files (default to ./logring)
    --trace   debug view
    --help    this help text

## Principle

Logring is a tool for remotely execute `request-log-analyzer` on a collection of remote servers (called nodes). The user executing logring is supposed to have its ssh keys already prepared on each remote hosts.

The remote execution is performed in parallel using [SSHKit](https://github.com/capistrano/sshkit). The generated reports are then transferred from the remote node and added to the local web directory.

The web interface that lists all reports is a static website with no magic. It's your business to decide were to put it and how to protect its access.

## Usage

Prepare a consistent config file with the list of nodes you want to control.

From logring directory (prefix with `bundle exec` if you need)

    logring list
    logring check
    logring init <host>

## Contributing

1. Fork it ( http://github.com/eduvo/logring/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## Authors

* @mose

## License

Copyright (c) 2014 Faria Systems Inc. Distributed under MIT License.
